// ================================================================
//  ContactUs.aspx.cs — COMPLETE
//  ERD: contact_us(message_id INT PK, student_id INT FK,
//                   subject_msg varchar, body_msg varchar,
//                   created_at_msg datetime)
// ================================================================
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class ContactUs : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        private int StudentId =>
            Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Pre-fill readonly fields from session
                txtName.Text = Session["StudentName"]?.ToString() ?? "";
                txtStudentId.Text = StudentId.ToString();
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            string subject = ddlSubject.SelectedValue.Trim();
            string message = txtMessage.Text.Trim();

            // Server-side validation
            if (string.IsNullOrEmpty(subject))
            {
                ShowError("Please select a subject for your message.");
                return;
            }

            if (string.IsNullOrEmpty(message))
            {
                ShowError("Please enter a message before sending.");
                return;
            }

            if (message.Length < 10)
            {
                ShowError("Message is too short. Please provide more detail (at least 10 characters).");
                return;
            }

            if (message.Length > 1000)
            {
                ShowError("Message exceeds maximum length of 1000 characters.");
                return;
            }

            // INSERT into contact_us table
            const string sql = @"
                INSERT INTO contact_us (student_id, subject_msg, body_msg, created_at_msg)
                VALUES (@sid, @subject, @body, GETDATE())";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    cmd.Parameters.AddWithValue("@subject", subject);
                    cmd.Parameters.AddWithValue("@body", message);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                // Success
                lblSuccess.Text = "&#10003; Your message has been sent successfully! Our team will respond within 1–2 business days.";
                lblSuccess.Visible = true;
                lblError.Visible = false;

                // Clear form
                txtMessage.Text = "";
                ddlSubject.SelectedIndex = 0;
            }
            catch (Exception ex)
            {
                ShowError("Failed to send message. Please try again. (" + ex.Message + ")");
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            lblError.Visible = true;
            lblSuccess.Visible = false;
        }
    }
}