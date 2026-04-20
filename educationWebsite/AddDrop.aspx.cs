using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace UniversitySystem
{
    public partial class AddDrop : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        private int StudentId =>
            Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;

        private string ActiveTab
        {
            get { return ViewState["ActiveTab"]?.ToString() ?? "enrolled"; }
            set { ViewState["ActiveTab"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            { Response.Redirect("~/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl)); return; }
            if (!IsPostBack) LoadActiveTab();
        }

        private void LoadActiveTab()
        {
            if (ActiveTab == "available")
            {
                pnlEnrolled.Visible = false;
                pnlAvailable.Visible = true;
                btnTabEnrolled.CssClass = "tab-btn";
                btnTabAvailable.CssClass = "tab-btn active";
                LoadAvailableCourses();
            }
            else
            {
                pnlEnrolled.Visible = true;
                pnlAvailable.Visible = false;
                btnTabEnrolled.CssClass = "tab-btn active";
                btnTabAvailable.CssClass = "tab-btn";
                LoadEnrolledCourses();
            }
        }

        protected void btnTab_Click(object sender, EventArgs e)
        {
            ActiveTab = ((Button)sender).CommandArgument;
            LoadActiveTab();
        }

        private void LoadEnrolledCourses()
        {
            const string sql =
                "SELECT e.enrollment_id, c.course_id, " +
                "       ISNULL(c.course_code, CAST(c.course_id AS VARCHAR(20))) AS course_code, " +
                "       c.course_name, " +
                "       ISNULL(c.credits, 0) AS credits, " +
                "       ISNULL(l.lecture_name, '—') AS lecture_name, " +
                "       ISNULL(c.class_room, '—') AS class_room " +
                "FROM enrollment e " +
                "JOIN course c ON c.course_id = e.course_id " +
                "LEFT JOIN lecture l ON l.lecture_id = c.lecture_id " +
                "WHERE e.student_id = @sid AND e.enrol_status = 'Active' " +
                "ORDER BY c.course_id";

            var list = new List<EnrolledCourse>();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 15;
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            list.Add(new EnrolledCourse
                            {
                                EnrollmentId = Convert.ToInt32(dr["enrollment_id"]),
                                CourseId = Convert.ToInt32(dr["course_id"]),
                                CourseCode = dr["course_code"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Credits = Convert.ToInt32(dr["credits"]),
                                LectureName = dr["lecture_name"].ToString(),
                                ClassRoom = dr["class_room"].ToString()
                            });
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Error loading courses: " + ex.Message); return; }

            phNoEnrolled.Visible = (list.Count == 0);
            rptEnrolled.DataSource = list;
            rptEnrolled.DataBind();
        }

        private void LoadAvailableCourses()
        {
            const string sql =
                "SELECT c.course_id, " +
                "       ISNULL(c.course_code, CAST(c.course_id AS VARCHAR(20))) AS course_code, " +
                "       c.course_name, " +
                "       ISNULL(c.credits, 0) AS credits, " +
                "       ISNULL(l.lecture_name, '—') AS lecture_name, " +
                "       ISNULL(c.class_room, '—') AS class_room " +
                "FROM course c " +
                "LEFT JOIN lecture l ON l.lecture_id = c.lecture_id " +
                "WHERE c.course_id NOT IN (" +
                "    SELECT course_id FROM enrollment " +
                "    WHERE student_id = @sid " +
                "      AND enrol_status IN ('Active','Pending Payment')" +
                ") ORDER BY c.course_id";

            var list = new List<AvailableCourse>();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 15;
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            list.Add(new AvailableCourse
                            {
                                CourseId = Convert.ToInt32(dr["course_id"]),
                                CourseCode = dr["course_code"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Credits = Convert.ToInt32(dr["credits"]),
                                LectureName = dr["lecture_name"].ToString(),
                                ClassRoom = dr["class_room"].ToString()
                            });
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Error loading courses: " + ex.Message); return; }

            phNoAvailable.Visible = (list.Count == 0);
            rptAvailable.DataSource = list;
            rptAvailable.DataBind();
        }

        protected void btnDrop_Click(object sender, EventArgs e)
        {
            int enrollmentId;
            if (!int.TryParse(((Button)sender).CommandArgument, out enrollmentId)) return;

            int courseId = 0;
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Ambil course_id (INT) sebelum update
                    using (var c = new SqlCommand(
                        "SELECT course_id FROM enrollment WHERE enrollment_id = @eid", con))
                    {
                        c.Parameters.AddWithValue("@eid", enrollmentId);
                        var res = c.ExecuteScalar();
                        if (res != null && res != DBNull.Value)
                            courseId = Convert.ToInt32(res);
                    }

                    using (var cmd = new SqlCommand(
                        "UPDATE enrollment SET enrol_status = 'Dropped' " +
                        "WHERE enrollment_id = @eid AND student_id = @sid", con))
                    {
                        cmd.Parameters.AddWithValue("@eid", enrollmentId);
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        cmd.ExecuteNonQuery();
                    }

                    if (courseId > 0)
                        RecordHistory(con, courseId, "Drop");
                }
                ShowSuccess("&#10003; Course dropped successfully.");
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Drop error: " + ex.Message); }

            ActiveTab = "enrolled";
            LoadActiveTab();
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            // CommandArgument = course_id (INT) sebagai string
            int courseId;
            if (!int.TryParse(((Button)sender).CommandArgument, out courseId) || courseId == 0)
            { ShowError("Invalid course."); return; }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Cek duplikat
                    using (var c = new SqlCommand(
                        "SELECT COUNT(*) FROM enrollment " +
                        "WHERE student_id = @sid AND course_id = @cid " +
                        "  AND enrol_status IN ('Active','Pending Payment')", con))
                    {
                        c.Parameters.AddWithValue("@sid", StudentId);
                        c.Parameters.AddWithValue("@cid", courseId);
                        if ((int)c.ExecuteScalar() > 0)
                        {
                            ShowError("Already enrolled or pending payment for this course.");
                            ActiveTab = "enrolled";
                            LoadActiveTab();
                            return;
                        }
                    }

                    // INSERT enrollment — enrollment_id auto IDENTITY, tidak perlu diisi
                    using (var cmd = new SqlCommand(
                        "INSERT INTO enrollment(student_id, course_id, enrol_data, enrol_status, is_completed, is_evaluated) " +
                        "VALUES(@sid, @cid, GETDATE(), 'Pending Payment', 0, 0)", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        cmd.Parameters.AddWithValue("@cid", courseId);
                        cmd.ExecuteNonQuery();
                    }

                    RecordHistory(con, courseId, "Add");
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Add error: " + ex.Message); return; }

            Response.Redirect("~/OnlinePayment.aspx?courses=" + courseId, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void RecordHistory(SqlConnection con, int courseId, string actionType)
        {
            const string checkSql =
                "SELECT COUNT(*) FROM add_drop_history " +
                "WHERE student_id=@sid AND course_id=@cid AND action_type=@act " +
                "  AND action_date = CAST(GETDATE() AS DATE)";
            const string insSql =
                "INSERT INTO add_drop_history(student_id, course_id, action_type, action_date) " +
                "VALUES(@sid, @cid, @act, CAST(GETDATE() AS DATE))";
            try
            {
                using (var chk = new SqlCommand(checkSql, con))
                {
                    chk.Parameters.AddWithValue("@sid", StudentId);
                    chk.Parameters.AddWithValue("@cid", courseId);
                    chk.Parameters.AddWithValue("@act", actionType);
                    if ((int)chk.ExecuteScalar() > 0) return;
                }
                using (var cmd = new SqlCommand(insSql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    cmd.Parameters.AddWithValue("@cid", courseId);
                    cmd.Parameters.AddWithValue("@act", actionType);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private static bool IsConnErr(SqlException ex) =>
            ex.Number == -2 || ex.Number == 2 || ex.Number == 53;

        private void RedirectTimeout()
        {
            Response.Redirect("~/Login.aspx?reason=timeout", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string m) { lblError.Text = m; lblError.Visible = true; lblSuccess.Visible = false; }
        private void ShowSuccess(string m) { lblSuccess.Text = m; lblSuccess.Visible = true; lblError.Visible = false; }

        public class EnrolledCourse
        {
            public int EnrollmentId { get; set; }
            public int CourseId { get; set; }
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public int Credits { get; set; }
            public string LectureName { get; set; }
            public string ClassRoom { get; set; }
        }

        public class AvailableCourse
        {
            public int CourseId { get; set; }
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public int Credits { get; set; }
            public string LectureName { get; set; }
            public string ClassRoom { get; set; }
        }
    }
}