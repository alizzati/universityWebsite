using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class TimetableMatching : Page
    {
        private static readonly string[] _colors = new[]
        {
            "#C0001D","#0066CC","#1A7A47","#8B5CF6","#D97706",
            "#0891B2","#BE185D","#4F7942","#DC2626","#2563EB"
        };

        private int? StudentId
        {
            get
            {
                if (Session["StudentId"] != null)
                    return Convert.ToInt32(Session["StudentId"]);
                return null;
            }
        }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (StudentId == null)
            {
                Response.Redirect("~/Login.aspx?reason=session", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                LoadStudentInfo();
                LoadCourses();
            }
        }

        private void LoadStudentInfo()
        {
            const string sql = "SELECT student_id, std_name FROM student WHERE student_id = @sid";
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 15;
                    cmd.Parameters.AddWithValue("@sid", StudentId.Value);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            lblStudentId.Text = dr["student_id"].ToString();
                            lblProgram.Text = dr["std_name"].ToString();
                        }
                    }
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); }
            catch { }
        }

        private void LoadCourses()
        {
            if (StudentId == null) return;

            const string sql = @"
            SELECT 
                c.course_id,
                c.course_code, 
                c.course_name, 
                c.credits, 
                ISNULL(l.lecture_name, '-') AS lecture_name, 
                ISNULL(c.class_room, 'TBA') AS Venue,
                c.[day] AS Day,
                c.start_time AS StartTime, 
                c.end_time AS EndTime
            FROM enrollment e
            JOIN course c ON e.course_id = c.course_id
            LEFT JOIN lecture l ON c.lecture_id = l.lecture_id
            WHERE e.student_id = @sid AND e.enrol_status = 'Active'";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        var scheduleList = new List<ScheduleRow>();
                        var courseList = new List<CourseRow>();

                        while (dr.Read())
                        {
                            string startRaw = dr["StartTime"].ToString();
                            string endRaw = dr["EndTime"].ToString();

                            scheduleList.Add(new ScheduleRow
                            {
                                CourseCode = dr["course_code"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Credits = Convert.ToInt32(dr["credits"]),
                                LectureName = dr["lecture_name"].ToString(),
                                Day = NormalizeDay(dr["Day"].ToString()),
                                StartTime = startRaw.Length >= 5 ? startRaw.Substring(0, 5) : startRaw,
                                EndTime = endRaw.Length >= 5 ? endRaw.Substring(0, 5) : endRaw,
                                Venue = dr["Venue"].ToString(),
                                Color = _colors[scheduleList.Count % _colors.Length]
                            });

                            courseList.Add(new CourseRow
                            {
                                CourseCode = dr["course_code"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                LectureName = dr["lecture_name"].ToString(),
                                Credits = Convert.ToInt32(dr["credits"]),
                                Day = NormalizeDay(dr["Day"].ToString())
                            });
                        }

                        // Bind table Enrolled Courses
                        rptCourses.DataSource = courseList;
                        rptCourses.DataBind();

                        // Bind schedule list & timetable grid
                        rptSchedule.DataSource = scheduleList;
                        rptSchedule.DataBind();
                        litTimetable.Text = BuildGridHtml(scheduleList);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Error loading enrolled courses: " + ex.Message);
            }
        }
        protected void btnShow_Click(object sender, EventArgs e)
        {
            if (StudentId == null) { RedirectTimeout(); return; }
            LoadTimetable(rbShowAll.Checked);
        }

        private void LoadTimetable(bool showAll)
        {
            // FIX: Hapus JOIN timetable, gunakan kolom dari tabel course (c)
            const string sql = @"
            SELECT 
                c.course_code, 
                c.course_name,
                ISNULL(l.lecture_name, '-') AS lecture_name,
                c.credits,
                c.[day] AS day_of_week, 
                c.start_time, 
                c.end_time, 
                ISNULL(c.class_room, 'TBA') AS venue 
            FROM enrollment e 
            JOIN course c ON c.course_id = e.course_id
            LEFT JOIN lecture l ON c.lecture_id = l.lecture_id
            WHERE e.student_id = @sid AND e.enrol_status = 'Active' 
            ORDER BY 
                CASE c.[day] 
                    WHEN 'Monday' THEN 1 
                    WHEN 'Tuesday' THEN 2 
                    WHEN 'Wednesday' THEN 3 
                    WHEN 'Thursday' THEN 4 
                    WHEN 'Friday' THEN 5 
                    WHEN 'Saturday' THEN 6
                    ELSE 7 END, 
                c.start_time";

            var schedules = new List<ScheduleRow>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 20;
                    cmd.Parameters.AddWithValue("@sid", StudentId.Value);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        int colorIdx = 0;
                        var colors = new Dictionary<string, string>();
                        while (dr.Read())
                        {
                            // Gunakan course_code sebagai identifier (misal: NET3204)
                            string code = dr["course_code"].ToString();
                            if (!colors.ContainsKey(code))
                                colors[code] = _colors[colorIdx++ % _colors.Length];

                            schedules.Add(new ScheduleRow
                            {
                                CourseCode = code,
                                CourseName = dr["course_name"].ToString(),
                                LectureName = dr["lecture_name"].ToString(),
                                Credits = dr["credits"] != DBNull.Value ? Convert.ToInt32(dr["credits"]) : 0,
                                Day = NormalizeDay(dr["day_of_week"].ToString()),
                                StartTime = FormatTime(dr["start_time"]),
                                EndTime = FormatTime(dr["end_time"]),
                                Venue = dr["venue"].ToString(),
                                Color = colors[code]
                            });
                        }
                    }
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Timetable error: " + ex.Message); return; }
            if (schedules.Count == 0)
            {
                ShowError("No timetable data found for your enrolled courses. Please contact the administration.");
                return;
            }

            var legendItems = new List<LegendItem>();
            var seen = new HashSet<string>();
            foreach (var s in schedules)
                if (seen.Add(s.CourseCode))
                    legendItems.Add(new LegendItem { CourseCode = s.CourseCode, Color = s.Color });

            rptLegend.DataSource = legendItems;
            rptLegend.DataBind();
            rptSchedule.DataSource = schedules;
            rptSchedule.DataBind();
            litTimetable.Text = BuildGridHtml(schedules);
            lblTimetableTitle.Text = showAll ? "ALL TIMETABLE SCHEDULE" : "MATCHED SCHEDULE";
            pnlTimetable.Visible = true;
        }

        private string BuildGridHtml(List<ScheduleRow> schedules)
        {
            var days = new[] { "MON", "TUE", "WED", "THU", "FRI", "SAT" };
            var hours = new[] { "8:00","9:00","10:00","11:00","12:00","13:00",
                                "14:00","15:00","16:00","17:00","18:00","19:00" };
            var sb = new System.Text.StringBuilder();

            sb.Append("<div class='tg-header-row'>");
            sb.Append("<div class='tg-time-col tg-header-cell'>Time</div>");
            foreach (var d in days)
                sb.AppendFormat("<div class='tg-day-cell tg-header-cell'>{0}</div>", d);
            sb.Append("</div>");

            foreach (var hour in hours)
            {
                sb.Append("<div class='tg-row'>");
                sb.AppendFormat("<div class='tg-time-col'>{0}</div>", hour);
                foreach (var day in days)
                {
                    sb.Append("<div class='tg-cell'>");
                    foreach (var s in schedules)
                    {
                        if (s.Day != day || !IsHourInSlot(hour, s.StartTime, s.EndTime)) continue;
                        sb.AppendFormat(
                            "<div class='tg-slot' style='background:{0};border-left-color:{0}'>" +
                            "<span class='tg-slot-code'>{1}</span>" +
                            "<span class='tg-slot-venue'>{2}</span></div>",
                            s.Color,
                            System.Web.HttpUtility.HtmlEncode(s.CourseCode),
                            System.Web.HttpUtility.HtmlEncode(s.Venue));
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
                var ep = endStr.Split(':');
                if (ep.Length > 1 && ep[1] == "00") end--;
                return hour >= start && hour <= end;
            }
            catch { return false; }
        }

        private string FormatTime(object val)
        {
            if (val == null || val == DBNull.Value) return "—";
            if (val is TimeSpan ts) return ts.Hours + ":" + ts.Minutes.ToString("D2");
            if (DateTime.TryParse(val.ToString(), out DateTime dt)) return dt.ToString("H:mm");
            return val.ToString();
        }

        // Normalises full day name or abbreviation → 3-letter uppercase used by the grid
        private static string NormalizeDay(string day)
        {
            if (string.IsNullOrWhiteSpace(day)) return "";
            switch (day.Trim().ToUpper())
            {
                case "MONDAY": case "MON": return "MON";
                case "TUESDAY": case "TUE": return "TUE";
                case "WEDNESDAY": case "WED": return "WED";
                case "THURSDAY": case "THU": return "THU";
                case "FRIDAY": case "FRI": return "FRI";
                case "SATURDAY": case "SAT": return "SAT";
                default: return day.Substring(0, Math.Min(3, day.Length)).ToUpper();
            }
        }

        private static bool IsConnErr(SqlException ex) =>
            ex.Number == -2 || ex.Number == 2 || ex.Number == 53 ||
            ex.Message.IndexOf("timeout", StringComparison.OrdinalIgnoreCase) >= 0;

        private void RedirectTimeout()
        {
            Response.Redirect("~/Login.aspx?reason=timeout", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string msg) { lblError.Text = msg; lblError.Visible = true; }

        public class CourseRow
        {
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public string LectureName { get; set; }
            public int Credits { get; set; }
            public string Day { get; set; }
        }
        public class ScheduleRow
        {
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public int Credits { get; set; }
            public string LectureName { get; set; }
            public string ClassRoom { get; set; }
            public int AvailableFor { get; set; }
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