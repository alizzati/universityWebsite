// ================================================================
//  OnlineEnrollment.aspx.cs
//  FLOW: Student checks multiple courses → clicks PROCEED TO PAYMENT
//        → all selected courses inserted as 'Pending Payment'
//        → redirect to OnlinePayment.aspx with course list in query string
//  Namespace: UniversitySystem | Session: "StudentId"
// ================================================================
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
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

        // ── Load all courses with enrollment status ───────────────────────
        private void LoadCourses()
        {
            const string sql =
                "SELECT c.course_id, c.course_name, " +
                "       ISNULL(c.credits, 3)        AS credits, " +
                "       ISNULL(l.lecture_name, '—') AS lecture_name, " +
                "       ISNULL(c.class_room,  '—')  AS class_room, " +
                "       ISNULL(e.enrol_status, 'None') AS enrol_status " +
                "FROM   course c " +
                "LEFT   JOIN lecture    l ON l.lecture_id = c.lecture_id " +
                "LEFT   JOIN enrollment e ON CAST(e.course_id AS VARCHAR(20)) = c.course_id " +
                "                        AND e.student_id = @sid " +
                "                        AND e.enrol_status IN ('Active','Pending Payment') " +
                "ORDER  BY c.course_id";

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
                                CourseId = dr["course_id"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Credits = Convert.ToInt32(dr["credits"]),
                                LectureName = dr["lecture_name"].ToString(),
                                ClassRoom = dr["class_room"].ToString(),
                                EnrolStatus = dr["enrol_status"].ToString()
                            });
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Failed to load courses: " + ex.Message); return; }

            phEmpty.Visible = (list.Count == 0);
            rptCourses.DataSource = list;
            rptCourses.DataBind();
        }

        private void LoadCreditHours()
        {
            const string sql =
                "SELECT ISNULL(SUM(c.credits), 0) " +
                "FROM   enrollment e " +
                "JOIN   course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                "WHERE  e.student_id = @sid AND e.enrol_status = 'Active'";
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    lblCreditHours.Text = cmd.ExecuteScalar().ToString();
                }
            }
            catch { lblCreditHours.Text = "0"; }
        }

        // ── PROCEED TO PAYMENT button ─────────────────────────────────────
        // Reads which checkboxes are ticked in the Repeater
        protected void btnProceedPayment_Click(object sender, EventArgs e)
        {
            var selectedCourseIds = new List<string>();

            // Walk through Repeater items and find checked checkboxes
            foreach (RepeaterItem item in rptCourses.Items)
            {
                var chk = item.FindControl("chkEnrol") as CheckBox;
                if (chk != null && chk.Checked)
                {
                    var hid = item.FindControl("hidCourseId") as HiddenField;
                    if (hid != null && !string.IsNullOrEmpty(hid.Value))
                        selectedCourseIds.Add(hid.Value);
                }
            }

            if (selectedCourseIds.Count == 0)
            {
                ShowError("Please select at least one course to enrol.");
                LoadCourses();
                return;
            }

            // Insert each selected course as 'Pending Payment'
            var enrolled = new List<string>();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    foreach (string courseId in selectedCourseIds)
                    {
                        // Already enrolled?
                        using (var c = new SqlCommand(
                            "SELECT COUNT(*) FROM enrollment " +
                            "WHERE student_id = @sid " +
                            "  AND CAST(course_id AS VARCHAR(20)) = @cid " +
                            "  AND enrol_status IN ('Active','Pending Payment')", con))
                        {
                            c.Parameters.AddWithValue("@sid", StudentId);
                            c.Parameters.AddWithValue("@cid", courseId);
                            if ((int)c.ExecuteScalar() > 0) continue; // skip duplicates
                        }

                        // Get INT course_id via row number
                        int courseIntId = 0;
                        using (var c = new SqlCommand(
                            "SELECT COUNT(*) FROM course c2 WHERE c2.course_id <= @cid", con))
                        {
                            c.Parameters.AddWithValue("@cid", courseId);
                            try { courseIntId = (int)c.ExecuteScalar(); }
                            catch { courseIntId = 1; }
                        }

                        // INSERT enrollment as 'Pending Payment'
                        bool inserted = false;
                        foreach (var col in new[] { "enroll_data", "enrol_data" })
                        {
                            try
                            {
                                string ins =
                                    "INSERT INTO enrollment(student_id,course_id," + col + ",enrol_status,is_completed) " +
                                    "VALUES(@sid,@cid,GETDATE(),'Pending Payment',0)";
                                using (var cmd = new SqlCommand(ins, con))
                                {
                                    cmd.Parameters.AddWithValue("@sid", StudentId);
                                    cmd.Parameters.AddWithValue("@cid", courseIntId);
                                    cmd.ExecuteNonQuery();
                                    inserted = true;
                                    break;
                                }
                            }
                            catch (SqlException sex) when (sex.Number == 207) { }
                        }

                        if (inserted)
                        {
                            enrolled.Add(courseId);
                            // Record in add_drop_history (non-critical)
                            try
                            {
                                using (var cmd = new SqlCommand(
                                    "INSERT INTO add_drop_history(student_id,course_id,action_type,action_date) " +
                                    "VALUES(@sid,@cid,'Add',CAST(GETDATE() AS DATE))", con))
                                {
                                    cmd.Parameters.AddWithValue("@sid", StudentId);
                                    cmd.Parameters.AddWithValue("@cid", courseIntId);
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            catch { }
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

            // Redirect to payment page with all enrolled course IDs
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
            public string CourseId { get; set; }
            public string CourseName { get; set; }
            public int Credits { get; set; }
            public string LectureName { get; set; }
            public string ClassRoom { get; set; }
            public string EnrolStatus { get; set; }
        }
    }
}