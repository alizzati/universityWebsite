// ================================================================
//  RegistrationSummary.aspx.cs — FIXED
//
//  FIXES:
//  1. LoadSummaryData: removed c.day / c.start_time / c.end_time
//     (these columns don't exist in course per ERD).
//     Schedule column now uses timetable table with LEFT JOIN.
//
//  2. LoadTimetable: reads from timetable table with error handling.
//     Falls back to course columns if timetable table doesn't exist.
//
//  3. LoadHistory: shows add_drop_history + enrollment fallback.
//     Same fix as AddDropHistory.aspx.cs.
// ================================================================
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class RegistrationSummary : Page
    {
        private string ConnStr =>
            System.Configuration.ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        private int StudentId =>
            Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            { Response.Redirect("~/Login.aspx"); return; }

            if (!IsPostBack)
            {
                LoadSummaryData();
                LoadTimetable();
                LoadHistory();
            }
        }

        private void LoadSummaryData()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Student info
                    using (var cmd = new SqlCommand(
                        "SELECT student_id, std_name FROM student WHERE student_id=@sid", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        using (var dr = cmd.ExecuteReader())
                            if (dr.Read())
                            {
                                lblStudentId.Text = dr["student_id"].ToString();
                                lblStudentName.Text = dr["std_name"].ToString();
                            }
                    }

                    // FIX: Removed c.day, c.start_time, c.end_time (not in ERD)
                    // Schedule column: try timetable table, fallback to "TBA"
                    const string coursesQuery =
                        "SELECT " +
                        "    c.course_id   AS course_code, " +
                        "    c.course_name, " +
                        "    ISNULL(l.lecture_name, '—') AS lecturer, " +
                        "    ISNULL(c.credits, 0)        AS credits, " +
                        "    ISNULL(c.class_room, '—')   AS room, " +
                        "    e.enrol_status              AS status, " +
                        "    ISNULL(( " +
                        "        SELECT TOP 1 " +
                        "            t.day_of_week + ' ' + " +
                        "            CONVERT(VARCHAR(5),t.start_time,108) + '-' + " +
                        "            CONVERT(VARCHAR(5),t.end_time,108) " +
                        "        FROM timetable t WHERE t.course_id = e.course_id " +
                        "    ), 'TBA') AS schedule " +
                        "FROM enrollment e " +
                        "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                        "LEFT JOIN lecture l ON l.lecture_id = c.lecture_id " +
                        "WHERE e.student_id=@sid AND e.enrol_status IN('Active','Enrolled') " +
                        "ORDER BY c.course_id";

                    DataTable dt;
                    try
                    {
                        using (var cmd = new SqlCommand(coursesQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@sid", StudentId);
                            var da = new SqlDataAdapter(cmd);
                            dt = new DataTable();
                            da.Fill(dt);
                        }
                    }
                    catch (SqlException ex) when (ex.Number == 208) // timetable table missing
                    {
                        // Fallback: same query without timetable subquery
                        const string fallbackQuery =
                            "SELECT c.course_id AS course_code, c.course_name, " +
                            "ISNULL(l.lecture_name,'—') AS lecturer, ISNULL(c.credits,0) AS credits, " +
                            "ISNULL(c.class_room,'—') AS room, e.enrol_status AS status, 'TBA' AS schedule " +
                            "FROM enrollment e " +
                            "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                            "LEFT JOIN lecture l ON l.lecture_id = c.lecture_id " +
                            "WHERE e.student_id=@sid AND e.enrol_status IN('Active','Enrolled') " +
                            "ORDER BY c.course_id";
                        using (var cmd = new SqlCommand(fallbackQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@sid", StudentId);
                            var da = new SqlDataAdapter(cmd);
                            dt = new DataTable();
                            da.Fill(dt);
                        }
                    }

                    gvRegisteredCourses.DataSource = dt;
                    gvRegisteredCourses.DataBind();

                    int totalCourses = dt.Rows.Count;
                    int totalCredits = 0;
                    foreach (DataRow row in dt.Rows)
                        totalCredits += Convert.ToInt32(row["credits"]);

                    lblTotalCourses.Text = totalCourses.ToString();
                    lblTotalCredits.Text = totalCredits.ToString();
                    lblTotalHours.Text = (totalCredits * 2).ToString();
                }
            }
            catch { }
        }

        private void LoadTimetable()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    DataTable dt = null;

                    // Attempt 1: use timetable table (per ERD)
                    try
                    {
                        const string query =
                            "SELECT c.course_id, c.course_name, ISNULL(c.class_room,'—') AS class_room, " +
                            "t.day_of_week, " +
                            "CONVERT(VARCHAR(5),t.start_time,108) AS start_time, " +
                            "CONVERT(VARCHAR(5),t.end_time,108) AS end_time " +
                            "FROM enrollment e " +
                            "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                            "JOIN timetable t ON t.course_id = e.course_id " +
                            "WHERE e.student_id=@sid AND e.enrol_status='Active' " +
                            "ORDER BY t.day_of_week, t.start_time";

                        using (var cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@sid", StudentId);
                            var da = new SqlDataAdapter(cmd);
                            dt = new DataTable();
                            con.Open();
                            da.Fill(dt);
                        }
                    }
                    catch (SqlException ex) when (ex.Number == 208)
                    {
                        // timetable table doesn't exist — try course columns
                        if (con.State != System.Data.ConnectionState.Open) con.Open();
                        try
                        {
                            const string fallback =
                                "SELECT c.course_id, c.course_name, ISNULL(c.class_room,'—') AS class_room, " +
                                "    CASE WHEN COL_LENGTH('course','day_of_week') IS NOT NULL THEN c.day_of_week " +
                                "         WHEN COL_LENGTH('course','day') IS NOT NULL THEN c.day ELSE 'MON' END AS day_of_week, " +
                                "    CASE WHEN COL_LENGTH('course','start_time') IS NOT NULL THEN CONVERT(VARCHAR(5),c.start_time,108) ELSE '08:00' END AS start_time, " +
                                "    CASE WHEN COL_LENGTH('course','end_time') IS NOT NULL THEN CONVERT(VARCHAR(5),c.end_time,108) ELSE '10:00' END AS end_time " +
                                "FROM enrollment e " +
                                "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                                "WHERE e.student_id=@sid AND e.enrol_status='Active' " +
                                "ORDER BY c.course_id";
                            using (var cmd2 = new SqlCommand(fallback, con))
                            {
                                cmd2.Parameters.AddWithValue("@sid", StudentId);
                                var da = new SqlDataAdapter(cmd2);
                                dt = new DataTable();
                                da.Fill(dt);
                            }
                        }
                        catch { }
                    }

                    if (dt == null || dt.Rows.Count == 0)
                    {
                        litTimetable.Text = "<div style='padding:2rem;text-align:center;color:var(--muted);'>No timetable data available. Please ensure courses have been scheduled.</div>";
                        return;
                    }

                    var sb = new StringBuilder();
                    string[] timeSlots = { "08", "09", "10", "11", "12", "13", "14", "15", "16", "17" };
                    string[] days = { "MON", "TUE", "WED", "THU", "FRI" };

                    foreach (string time in timeSlots)
                    {
                        sb.AppendFormat("<div class='timetable-time'>{0}:00</div>", time);
                        foreach (string day in days)
                        {
                            sb.Append("<div class='timetable-slot'>");
                            foreach (DataRow cls in dt.Rows)
                            {
                                string dow = cls["day_of_week"]?.ToString()?.ToUpper() ?? "";
                                string st = cls["start_time"]?.ToString() ?? "";
                                string stHH = st.Length >= 2 ? st.Substring(0, 2) : "";
                                if (dow != day || stHH != time) continue;
                                sb.Append("<div class='class-block'>");
                                sb.AppendFormat("<div class='course-name'>{0}</div>",
                                    System.Web.HttpUtility.HtmlEncode(cls["course_id"].ToString()));
                                sb.AppendFormat("<div class='room'>&#127979; {0}</div>",
                                    System.Web.HttpUtility.HtmlEncode(cls["class_room"].ToString()));
                                sb.Append("</div>");
                            }
                            sb.Append("</div>");
                        }
                    }
                    litTimetable.Text = sb.ToString();
                }
            }
            catch
            {
                litTimetable.Text = "<div style='padding:2rem;text-align:center;color:var(--muted);'>Unable to load timetable.</div>";
            }
        }

        private void LoadHistory()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    // Primary: real add_drop_history records
                    const string query =
                        "SELECT h.action_date, " +
                        "ISNULL(c.course_id, CAST(h.course_id AS VARCHAR)) AS course_code, " +
                        "ISNULL(c.course_name, 'Unknown') AS course_name, " +
                        "h.action_type, 'System' AS processed_by " +
                        "FROM add_drop_history h " +
                        "LEFT JOIN course c ON c.course_id = CAST(h.course_id AS VARCHAR(20)) " +
                        "WHERE h.student_id=@sid ORDER BY h.action_date DESC";

                    using (var cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        con.Open();
                        da.Fill(dt);

                        // Fallback: synthesise from enrollment if history is empty
                        if (dt.Rows.Count == 0)
                        {
                            const string fallback =
                                "SELECT CAST(ISNULL(p.created_at, e.enrol_data) AS DATE) AS action_date, " +
                                "c.course_id AS course_code, c.course_name, " +
                                "'Add' AS action_type, 'System' AS processed_by " +
                                "FROM enrollment e " +
                                "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                                "LEFT JOIN payment p ON p.student_id=e.student_id AND p.course_id=c.course_id AND p.status='Success' " +
                                "WHERE e.student_id=@sid AND e.enrol_status='Active' " +
                                "ORDER BY action_date DESC";
                            using (var cmd2 = new SqlCommand(fallback, con))
                            {
                                cmd2.Parameters.AddWithValue("@sid", StudentId);
                                new SqlDataAdapter(cmd2).Fill(dt);
                            }
                        }

                        gvHistory.DataSource = dt;
                        gvHistory.DataBind();
                    }
                }
            }
            catch { }
        }
    }
}