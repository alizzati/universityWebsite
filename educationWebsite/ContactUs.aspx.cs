using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace UniversitySystem
{
    public partial class ContactUs : Page
    {
        private string ConnStr => ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;
        private int StudentId => Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null) { Response.Redirect("~/Login.aspx"); return; }
            if (!IsPostBack)
            {
                txtName.Text = Session["StudentName"]?.ToString() ?? "";
                txtStudentId.Text = StudentId.ToString();
                LoadEnrolledCourseSubjects();
            }
        }

        private void LoadEnrolledCourseSubjects()
        {
            ddlSubject.Items.Clear();
            ddlSubject.Items.Add(new ListItem("— Select a subject —", ""));

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    const string sql =
                        "SELECT DISTINCT c.course_id, c.course_name " +
                        "FROM enrollment e " +
                        "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                        "WHERE e.student_id = @sid " +
                        "ORDER BY c.course_id";

                    using (var cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        con.Open();
                        using (var dr = cmd.ExecuteReader())
                            while (dr.Read())
                            {
                                string courseId = dr["course_id"].ToString();
                                string courseName = dr["course_name"].ToString();
                                ddlSubject.Items.Add(new ListItem(
                                    courseId + " — " + courseName,
                                    "Course Inquiry: " + courseId + " - " + courseName));
                            }
                    }
                }
            }
            catch { }

            ddlSubject.Items.Add(new ListItem("Payment / Finance Issue", "Payment / Finance Issue"));
            ddlSubject.Items.Add(new ListItem("Timetable Query", "Timetable Query"));
            ddlSubject.Items.Add(new ListItem("Technical Support (Portal)", "Technical Support (Portal)"));
            ddlSubject.Items.Add(new ListItem("Add / Drop Course Query", "Add / Drop Course Query"));
            ddlSubject.Items.Add(new ListItem("Other", "Other"));
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string subject = ddlSubject.SelectedValue.Trim();
            string message = txtMessage.Text.Trim();

            if (string.IsNullOrEmpty(subject)) { ShowError("Please select a subject."); return; }
            if (string.IsNullOrEmpty(message)) { ShowError("Please enter a message."); return; }
            if (message.Length < 10) { ShowError("Message is too short (minimum 10 characters)."); return; }
            if (message.Length > 1000) { ShowError("Message exceeds maximum 1000 characters."); return; }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("INSERT INTO contact_us(student_id,subject_msg,body_msg,created_at_msg) VALUES(@sid,@subject,@body,GETDATE())", con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    cmd.Parameters.AddWithValue("@subject", subject);
                    cmd.Parameters.AddWithValue("@body", message);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
                lblSuccess.Text = "&#10003; Message sent successfully! We will respond within 1–2 business days.";
                lblSuccess.Visible = true; lblError.Visible = false;
                txtMessage.Text = ""; ddlSubject.SelectedIndex = 0;
            }
            catch (Exception ex) { ShowError("Failed to send: " + ex.Message); }
        }

        private void ShowSuccess(string msg) { lblSuccess.Text = msg; lblSuccess.Visible = true; lblError.Visible = false; }
        private void ShowError(string msg) { lblError.Text = msg; lblError.Visible = true; lblSuccess.Visible = false; }
    }
}