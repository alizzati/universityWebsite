// ================================================================
//  RegistrationSummary.aspx.cs — FIXED
//  FIX 1: All JOINs use CAST(e.course_id AS VARCHAR(20)) = c.course_id
//  FIX 2: add_drop_history JOIN uses CAST(h.course_id AS VARCHAR(20))
//  FIX 3: Session["StudentId"] consistent
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
        private string connectionString =
            System.Configuration.ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }
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

                    // FIX: CAST for course_id join
                    const string coursesQuery = @"
                        SELECT
                            c.course_id AS course_code,
                            c.course_name,
                            ISNULL(l.lecture_name, '—') AS lecturer,
                            ISNULL(c.credits, 0)        AS credits,
                            ISNULL(c.class_room, '—')   AS room,
                            e.enrol_status              AS status,
                            ISNULL(
                                (SELECT TOP 1 CONVERT(varchar,t.day_of_week)+' '+
                                 CONVERT(varchar,t.start_time,108)+'-'+
                                 CONVERT(varchar,t.end_time,108)
                                 FROM timetable t WHERE t.course_id = e.course_id),
                                '—'
                            ) AS schedule
                        FROM   enrollment e
                        JOIN   course   c ON c.course_id  = CAST(e.course_id AS VARCHAR(20))
                        LEFT   JOIN lecture l ON l.lecture_id = c.lecture_id
                        WHERE  e.student_id   = @sid
                          AND  e.enrol_status IN ('Active','Enrolled')";

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
            int studentId = Convert.ToInt32(Session["StudentId"]);
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    // FIX: CAST course_id in both joins
                    const string query = @"
                        SELECT c.course_id, c.course_name, ISNULL(c.class_room,'—') AS class_room,
                               t.day_of_week, t.start_time, t.end_time
                        FROM   enrollment e
                        JOIN   course     c ON c.course_id = CAST(e.course_id AS VARCHAR(20))
                        JOIN   timetable  t ON t.course_id = e.course_id
                        WHERE  e.student_id   = @sid
                          AND  e.enrol_status = 'Active'
                        ORDER  BY t.start_time";

                    using (var cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        conn.Open();
                        da.Fill(dt);

                        if (dt.Rows.Count == 0)
                        {
                            litTimetable.Text = "<div style='padding:2rem;text-align:center;color:var(--muted);'>No timetable data available.</div>";
                            return;
                        }

                        var sb = new StringBuilder();
                        string[] timeSlots = { "08", "10", "12", "14", "16" };
                        string[] days = { "MON", "TUE", "WED", "THU", "FRI" };

                        foreach (string time in timeSlots)
                        {
                            sb.AppendFormat("<div class='timetable-time'>{0}:00</div>", time);
                            foreach (string day in days)
                            {
                                sb.Append("<div class='timetable-slot'>");
                                foreach (DataRow cls in dt.Rows)
                                {
                                    string dow = cls["day_of_week"].ToString().ToUpper();
                                    string st = DateTime.TryParse(cls["start_time"].ToString(), out DateTime dtStart)
                                                 ? dtStart.ToString("HH") : "";
                                    if (dow != day || st != time) continue;

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
            }
            catch
            {
                litTimetable.Text = "<div style='padding:2rem;text-align:center;color:var(--muted);'>Unable to load timetable.</div>";
            }
        }

        private void LoadHistory()
        {
            int studentId = Convert.ToInt32(Session["StudentId"]);
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    // FIX: CAST h.course_id AS VARCHAR to join with course.course_id VARCHAR
                    const string query = @"
                        SELECT
                            h.action_date,
                            ISNULL(c.course_id,   CAST(h.course_id AS VARCHAR)) AS course_code,
                            ISNULL(c.course_name, 'Unknown')                    AS course_name,
                            h.action_type,
                            'System' AS processed_by
                        FROM   add_drop_history h
                        LEFT   JOIN course c ON c.course_id = CAST(h.course_id AS VARCHAR(20))
                        WHERE  h.student_id = @sid
                        ORDER  BY h.action_date DESC";

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