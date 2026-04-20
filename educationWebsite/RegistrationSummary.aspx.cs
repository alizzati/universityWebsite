using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class RegistrationSummary : Page
    {
        private string connectionString =
            System.Configuration.ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

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
            int studentId = Convert.ToInt32(Session["StudentId"]);
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT student_id, std_name FROM student WHERE student_id = @sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        using (var dr = cmd.ExecuteReader())
                            if (dr.Read())
                            {
                                lblStudentId.Text = dr["student_id"].ToString();
                                lblStudentName.Text = dr["std_name"].ToString();
                            }
                    }

                    // course_id sekarang INT di semua tabel — JOIN langsung tanpa CAST
                    const string coursesQuery =
                        "SELECT " +
                        "    ISNULL(c.course_code, CAST(c.course_id AS VARCHAR(20))) AS course_code, " +
                        "    c.course_name, " +
                        "    ISNULL(l.lecture_name, '—') AS lecturer, " +
                        "    ISNULL(c.credits, 0) AS credits, " +
                        "    ISNULL(c.class_room, '—') AS room, " +
                        "    e.enrol_status AS status, " +
                        "    ISNULL((" +
                        "        SELECT TOP 1 " +
                        "            CONVERT(varchar, c2.day) + ' ' + " +
                        "            CONVERT(varchar, c2.start_time, 108) + '-' + " +
                        "            CONVERT(varchar, c2.end_time, 108) " +
                        "        FROM course c2 WHERE c2.course_id = e.course_id" +
                        "    ), '—') AS schedule " +
                        "FROM enrollment e " +
                        "JOIN course c ON c.course_id = e.course_id " +
                        "LEFT JOIN lecture l ON l.lecture_id = c.lecture_id " +
                        "WHERE e.student_id = @sid " +
                        "  AND e.enrol_status = 'Active' " +
                        "ORDER BY c.course_id";

                    using (var cmd = new SqlCommand(coursesQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);

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
            }
            catch { }
        }
        private void LoadTimetable()
        {
            if (Session["StudentId"] == null) return;
            int studentId = Convert.ToInt32(Session["StudentId"]);

            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    // 1. Tambahkan kolom 'day' (bukan day_of_week) dan pastikan start_time ikut diambil
                    const string query = @"
                SELECT 
                    c.course_code, 
                    c.course_name, 
                    c.[day], 
                    c.start_time,
                    c.class_room
                FROM enrollment e
                JOIN course c ON e.course_id = c.course_id
                WHERE e.student_id = @sid AND e.enrol_status = 'Active'";

                    using (var cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        conn.Open();
                        da.Fill(dt);

                        if (dt.Rows.Count == 0)
                        {
                            litTimetable.Text = "<div style='padding:2rem;text-align:center;color:var(--muted);'>No active courses found. Please complete payment first.</div>";
                            return;
                        }

                        var sb = new StringBuilder();
                        string[] timeSlots = { "08", "09", "10", "11", "12", "13", "14", "15", "16", "17" };

                        // 2. Samakan format hari dengan yang ada di Database (Monday, Tuesday, dst)
                        string[] days = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday" };

                        foreach (string time in timeSlots)
                        {
                            sb.AppendFormat("<div class='timetable-time'>{0}:00</div>", time);
                            foreach (string dayName in days)
                            {
                                sb.Append("<div class='timetable-slot'>");
                                foreach (DataRow cls in dt.Rows)
                                {
                                    // 3. Gunakan nama kolom [day] sesuai Database
                                    string dbDay = cls["day"].ToString();

                                    // Ambil jam (HH) dari start_time
                                    string dbStartHour = "";
                                    if (cls["start_time"] != DBNull.Value)
                                    {
                                        // Tipe TIME di SQL dibaca sebagai TimeSpan di C#
                                        TimeSpan ts = (TimeSpan)cls["start_time"];
                                        dbStartHour = ts.Hours.ToString("D2");
                                    }

                                    // Bandingkan hari dan jam
                                    if (dbDay.Equals(dayName, StringComparison.OrdinalIgnoreCase) && dbStartHour == time)
                                    {
                                        sb.Append("<div class='class-block'>");
                                        sb.AppendFormat("<div class='course-name'>{0}</div>",
                                            System.Web.HttpUtility.HtmlEncode(cls["course_code"].ToString()));
                                        sb.AppendFormat("<div class='room'>&#127979; {0}</div>",
                                            System.Web.HttpUtility.HtmlEncode(cls["class_room"].ToString()));
                                        sb.Append("</div>");
                                    }
                                }
                                sb.Append("</div>");
                            }
                        }
                        litTimetable.Text = sb.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                litTimetable.Text = "<div style='padding:2rem;text-align:center;color:red;'>Error: " + ex.Message + "</div>";
            }
        }

        private void LoadHistory()
        {
            int studentId = Convert.ToInt32(Session["StudentId"]);
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    // add_drop_history.course_id = INT FK → course.course_id INT
                    const string query =
                        "SELECT " +
                        "    h.action_date, " +
                        "    ISNULL(c.course_code, CAST(c.course_id AS VARCHAR(20))) AS course_code, " +
                        "    ISNULL(c.course_name, 'Unknown') AS course_name, " +
                        "    h.action_type, " +
                        "    'System' AS processed_by " +
                        "FROM add_drop_history h " +
                        "LEFT JOIN course c ON c.course_id = h.course_id " +
                        "WHERE h.student_id = @sid " +
                        "ORDER BY h.action_date DESC";

                    using (var cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        conn.Open();
                        da.Fill(dt);
                        gvHistory.DataSource = dt;
                        gvHistory.DataBind();
                    }
                }
            }
            catch { }
        }
    }
}