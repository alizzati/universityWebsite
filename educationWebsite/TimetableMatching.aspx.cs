using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using WebGrease.Activities;

namespace UniversitySystem
{
    public partial class TimetableMatching : Page
    {
        // ── Course colors for visual distinction ──────────────────────────
        private static readonly string[] _colors = new[]
        {
            "#C0001D", "#0066CC", "#1A7A47", "#8B5CF6", "#D97706",
            "#0891B2", "#BE185D", "#4F7942", "#DC2626", "#2563EB"
        };

        private int StudentId
        {
            get
            {
                // Replace with: return Convert.ToInt32(Session["StudentId"]);
                return 1;
            }
        }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        // ════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStudentInfo();
                LoadCourses();
            }
        }

        // ════════════════════════════════════════════════════════════════
        //  LOAD STUDENT INFO
        // ════════════════════════════════════════════════════════════════
        private void LoadStudentInfo()
        {
            const string sql = @"
                SELECT s.student_id, s.student_name, p.program_name
                FROM   student  s
                JOIN   program  p ON p.program_id = s.program_id
                WHERE  s.student_id = @sid";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblStudentId.Text = dr["student_id"].ToString();
                            lblProgram.Text = dr["program_name"].ToString();
                        }
                    }
                }
            }
            catch { /* use default labels */ }
        }

        // ════════════════════════════════════════════════════════════════
        //  LOAD COURSES (enrolled, read-only display)
        // ════════════════════════════════════════════════════════════════
        private void LoadCourses()
        {
            const string sql = @"
                SELECT c.course_id, c.course_name, e.section
                FROM   enrollment e
                JOIN   course     c ON c.course_id = CAST(e.course_id AS VARCHAR(20))
                WHERE  e.student_id   = @sid
                  AND  e.enrol_status = 'Active'
                ORDER  BY c.course_id ASC";

            var list = new List<CourseRow>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            list.Add(new CourseRow
                            {
                                CourseCode = dr["course_id"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Section = dr["section"] == DBNull.Value ? "—" : dr["section"].ToString()
                            });
                }
            }
            catch (Exception ex) { ShowError("Failed to load courses: " + ex.Message); }

            rptCourses.DataSource = list;
            rptCourses.DataBind();
        }

        // ════════════════════════════════════════════════════════════════
        //  SHOW TIMETABLE BUTTON
        // ════════════════════════════════════════════════════════════════
        protected void btnShow_Click(object sender, EventArgs e)
        {
            bool showAll = rbShowAll.Checked;
            LoadTimetable(showAll);
        }

        // ════════════════════════════════════════════════════════════════
        //  LOAD TIMETABLE DATA
        // ════════════════════════════════════════════════════════════════
        private void LoadTimetable(bool showAll)
        {
            // SQL: get schedule from timetable table
            // Adjust table/column names to your actual schema
            string sql = showAll
                ? @"
                    SELECT c.course_id, c.course_name, t.day_of_week, t.start_time, t.end_time,
                           t.venue, e.section
                    FROM   timetable   t
                    JOIN   course      c  ON c.course_id  = CAST(t.course_id AS VARCHAR(20))
                    JOIN   enrollment  e  ON CAST(e.course_id AS VARCHAR(20)) = c.course_id
                                         AND e.student_id = @sid
                                         AND e.enrol_status = 'Active'
                    ORDER  BY FIELD(t.day_of_week,'MON','TUE','WED','THU','FRI','SAT'), t.start_time"
                : @"
                    SELECT c.course_id, c.course_name, t.day_of_week, t.start_time, t.end_time,
                           t.venue, e.section
                    FROM   timetable   t
                    JOIN   course      c  ON c.course_id  = CAST(t.course_id AS VARCHAR(20))
                    JOIN   enrollment  e  ON CAST(e.course_id AS VARCHAR(20)) = c.course_id
                                         AND e.student_id = @sid
                                         AND e.enrol_status = 'Active'
                                         AND e.section     = t.section
                    ORDER  BY FIELD(t.day_of_week,'MON','TUE','WED','THU','FRI','SAT'), t.start_time";

            var schedules = new List<ScheduleRow>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        int colorIdx = 0;
                        var courseColors = new Dictionary<string, string>();

                        while (dr.Read())
                        {
                            string code = dr["course_id"].ToString();
                            if (!courseColors.ContainsKey(code))
                            {
                                courseColors[code] = _colors[colorIdx % _colors.Length];
                                colorIdx++;
                            }

                            schedules.Add(new ScheduleRow
                            {
                                CourseCode = code,
                                CourseName = dr["course_name"].ToString(),
                                Day = dr["day_of_week"].ToString(),
                                StartTime = FormatTime(dr["start_time"]),
                                EndTime = FormatTime(dr["end_time"]),
                                Venue = dr["venue"] == DBNull.Value ? "TBA" : dr["venue"].ToString(),
                                Color = courseColors[code]
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Failed to load timetable: " + ex.Message);
                return;
            }

            // ── If no DB data, show placeholder (dev mode) ──
            if (schedules.Count == 0)
                schedules = GetDemoSchedules();

            // ── Bind legend ──
            var legendItems = new List<LegendItem>();
            var seen = new HashSet<string>();
            foreach (var s in schedules)
                if (seen.Add(s.CourseCode))
                    legendItems.Add(new LegendItem { CourseCode = s.CourseCode, Color = s.Color });

            rptLegend.DataSource = legendItems;
            rptLegend.DataBind();

            // ── Bind schedule list ──
            rptSchedule.DataSource = schedules;
            rptSchedule.DataBind();

            // ── Build grid HTML ──
            litTimetable.Text = BuildGridHtml(schedules);

            lblTimetableTitle.Text = showAll ? "ALL TIMETABLE SCHEDULE" : "MATCHED SCHEDULE";
            pnlTimetable.Visible = true;
        }

        // ════════════════════════════════════════════════════════════════
        //  BUILD HTML GRID
        // ════════════════════════════════════════════════════════════════
        private string BuildGridHtml(List<ScheduleRow> schedules)
        {
            var days = new[] { "MON", "TUE", "WED", "THU", "FRI", "SAT" };
            var hours = new[] { "8:00", "9:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00" };

            var sb = new System.Text.StringBuilder();

            // Header row
            sb.Append("<div class='tg-header-row'>");
            sb.Append("<div class='tg-time-col tg-header-cell'>Time</div>");
            foreach (var d in days)
                sb.AppendFormat("<div class='tg-day-cell tg-header-cell'>{0}</div>", d);
            sb.Append("</div>");

            // Hour rows
            foreach (var hour in hours)
            {
                sb.Append("<div class='tg-row'>");
                sb.AppendFormat("<div class='tg-time-col'>{0}</div>", hour);

                foreach (var day in days)
                {
                    sb.Append("<div class='tg-cell'>");

                    foreach (var s in schedules)
                    {
                        if (s.Day.ToUpper() != day) continue;
                        // Check if this hour falls within start-end
                        if (IsHourInSlot(hour, s.StartTime, s.EndTime))
                        {
                            sb.AppendFormat(
                                "<div class='tg-slot' style='background:{0};border-color:{0}'>" +
                                "<span class='tg-slot-code'>{1}</span>" +
                                "<span class='tg-slot-venue'>{2}</span>" +
                                "</div>",
                                s.Color,
                                System.Web.HttpUtility.HtmlEncode(s.CourseCode),
                                System.Web.HttpUtility.HtmlEncode(s.Venue));
                        }
                    }

                    sb.Append("</div>");
                }

                sb.Append("</div>");
            }

            return sb.ToString();
        }

        private bool IsHourInSlot(string hourStr, string startStr, string endStr)
        {
            try
            {
                int hour = int.Parse(hourStr.Split(':')[0]);
                int start = int.Parse(startStr.Split(':')[0]);
                int end = int.Parse(endStr.Split(':')[0]);
                if (endStr.Contains(":") && endStr.Split(':')[1] == "00") end--;
                return hour >= start && hour <= end;
            }
            catch { return false; }
        }

        private string FormatTime(object val)
        {
            if (val == null || val == DBNull.Value) return "—";
            if (val is TimeSpan ts) return ts.ToString(@"h\:mm");
            if (DateTime.TryParse(val.ToString(), out DateTime dt)) return dt.ToString("H:mm");
            return val.ToString();
        }

        // ════════════════════════════════════════════════════════════════
        //  DEMO DATA (used when DB has no records, for development)
        // ════════════════════════════════════════════════════════════════
        private List<ScheduleRow> GetDemoSchedules()
        {
            return new List<ScheduleRow>
            {
                new ScheduleRow { CourseCode="EEC1001", CourseName="English Enhancement Course",                   Day="MON", StartTime="8:00",  EndTime="10:00", Venue="DK1",   Color="#C0001D" },
                new ScheduleRow { CourseCode="IBM3201M",CourseName="Data Mining and Predictive Analytics",         Day="TUE", StartTime="10:00", EndTime="12:00", Venue="Lab A", Color="#0066CC" },
                new ScheduleRow { CourseCode="IBM3204M",CourseName="Cloud Computing Architecture",                 Day="WED", StartTime="14:00", EndTime="16:00", Venue="DK3",   Color="#1A7A47" },
                new ScheduleRow { CourseCode="NET3203M",CourseName="Cybersecurity",                                Day="THU", StartTime="9:00",  EndTime="11:00", Venue="Lab B", Color="#8B5CF6" },
                new ScheduleRow { CourseCode="PRG3204M",CourseName="Web Application Development",                  Day="FRI", StartTime="13:00", EndTime="15:00", Venue="Lab C", Color="#D97706" },
                new ScheduleRow { CourseCode="EEC1001", CourseName="English Enhancement Course",                   Day="WED", StartTime="10:00", EndTime="12:00", Venue="DK1",   Color="#C0001D" },
            };
        }

        // ════════════════════════════════════════════════════════════════
        //  UI HELPERS
        // ════════════════════════════════════════════════════════════════
        private void ShowError(string msg)
        {
            lblError.Text = msg;
            lblError.Visible = true;
        }

        // ════════════════════════════════════════════════════════════════
        //  VIEW MODELS
        // ════════════════════════════════════════════════════════════════
        public class CourseRow
        {
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public string Section { get; set; }
        }

        public class ScheduleRow
        {
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public string Day { get; set; }
            public string StartTime { get; set; }
            public string EndTime { get; set; }
            public string Venue { get; set; }
            public string Color { get; set; }
        }

        public class LegendItem
        {
            public string CourseCode { get; set; }
            public string Color { get; set; }
        }
    }
}