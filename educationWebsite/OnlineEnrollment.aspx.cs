using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace UniversitySystem
{
    public partial class OnlineEnrollment : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        private int StudentId =>
            Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            { Response.Redirect("~/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl)); return; }

            if (!IsPostBack)
            {
                lblStudentName.Text = Session["StudentName"]?.ToString() ?? "Student";
                lblStudentId.Text = StudentId.ToString();
                LoadCourses();
                LoadCreditHours();
            }
        }

        private void LoadCourses()
        {
            // course_id sekarang INT IDENTITY — tidak perlu CAST
            // Tampilkan course_code (VARCHAR) ke user untuk label
            const string sql =
                "SELECT " +
                "    c.course_id, " +
                "    ISNULL(c.course_code, CAST(c.course_id AS VARCHAR(20))) AS course_code, " +
                "    c.course_name, " +
                "    ISNULL(c.credits, 3) AS credits, " +
                "    ISNULL(l.lecture_name, '—') AS lecture_name, " +
                "    ISNULL(c.class_room, '—') AS class_room " +
                "FROM course c " +
                "LEFT JOIN lecture l ON l.lecture_id = c.lecture_id " +
                "WHERE NOT EXISTS ( " +
                "    SELECT 1 FROM enrollment e " +
                "    WHERE e.student_id = @sid " +
                "      AND e.course_id  = c.course_id " +
                "      AND e.enrol_status IN ('Active', 'Pending Payment') " +
                ") " +
                "ORDER BY c.course_id ASC";

            var list = new List<CourseItem>();
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
                            list.Add(new CourseItem
                            {
                                CourseId = Convert.ToInt32(dr["course_id"]),
                                CourseCode = dr["course_code"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Credits = Convert.ToInt32(dr["credits"]),
                                LectureName = dr["lecture_name"].ToString(),
                                ClassRoom = dr["class_room"].ToString(),
                                EnrolStatus = "None"
                            });
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Failed to load courses: " + ex.Message); return; }

            phEmpty.Visible = (list.Count == 0);
            if (list.Count > 0)
            {
                rptCourses.DataSource = list;
                rptCourses.DataBind();
            }
        }

        private void LoadCreditHours()
        {
            const string sql =
                "SELECT ISNULL(SUM(c.credits), 0) " +
                "FROM enrollment e " +
                "JOIN course c ON c.course_id = e.course_id " +
                "WHERE e.student_id = @sid AND e.enrol_status = 'Active'";
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    lblCreditHours.Text = cmd.ExecuteScalar()?.ToString() ?? "0";
                }
            }
            catch { lblCreditHours.Text = "0"; }
        }

        protected void btnProceedPayment_Click(object sender, EventArgs e)
        {
            var selected = new List<int>(); // sekarang pakai INT

            foreach (RepeaterItem item in rptCourses.Items)
            {
                var chk = item.FindControl("chkEnrol") as CheckBox;
                if (chk == null || !chk.Checked) continue;
                var hid = item.FindControl("hidCourseId") as HiddenField;
                int cid;
                if (hid != null && int.TryParse(hid.Value, out cid))
                    selected.Add(cid);
            }

            if (selected.Count == 0)
            {
                ShowError("Please select at least one course to enrol.");
                LoadCourses();
                return;
            }

            var enrolled = new List<int>();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    foreach (int courseId in selected)
                    {
                        // Cek duplikat — INT vs INT, tidak perlu CAST
                        using (var c = new SqlCommand(
                            "SELECT COUNT(*) FROM enrollment " +
                            "WHERE student_id = @sid " +
                            "  AND course_id   = @cid " +
                            "  AND enrol_status IN ('Active','Pending Payment')", con))
                        {
                            c.Parameters.AddWithValue("@sid", StudentId);
                            c.Parameters.AddWithValue("@cid", courseId);
                            if ((int)c.ExecuteScalar() > 0) continue;
                        }

                        // INSERT enrollment
                        // enrollment_id = IDENTITY → tidak perlu diisi
                        // enrol_data    = kolom tanggal sesuai skema DB
                        using (var cmd = new SqlCommand(
                            "INSERT INTO enrollment(student_id, course_id, enrol_data, enrol_status, is_completed, is_evaluated) " +
                            "VALUES(@sid, @cid, GETDATE(), 'Pending Payment', 0, 0)", con))
                        {
                            cmd.Parameters.AddWithValue("@sid", StudentId);
                            cmd.Parameters.AddWithValue("@cid", courseId);
                            cmd.ExecuteNonQuery();
                            enrolled.Add(courseId);
                        }
                    }
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Enrolment error: " + ex.Message); return; }

            if (enrolled.Count == 0)
            {
                ShowError("All selected courses are already enrolled or pending payment.");
                LoadCourses();
                return;
            }

            // Kirim INT course_id ke OnlinePayment via querystring
            string courses = string.Join(",", enrolled);
            Response.Redirect("~/OnlinePayment.aspx?courses=" + Server.UrlEncode(courses), false);
            Context.ApplicationInstance.CompleteRequest();
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

        public class CourseItem
        {
            public int CourseId { get; set; }
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public int Credits { get; set; }
            public string LectureName { get; set; }
            public string ClassRoom { get; set; }
            public string EnrolStatus { get; set; }
        }
    }
}