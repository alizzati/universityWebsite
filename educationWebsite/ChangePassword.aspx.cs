// ================================================================
//  ChangePassword.aspx.cs — COMPLETE
//  Uses plaintext password comparison (consistent with Login.aspx)
//  ERD: student(student_id, std_name, std_email, std_password, ...)
// ================================================================
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class ChangePassword : Page
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
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string currentPwd = txtCurrentPassword.Text; // do NOT trim passwords
            string newPwd = txtNewPassword.Text;
            string confirmPwd = txtConfirmPassword.Text;

            // Extra server-side check (CompareValidator handles client-side)
            if (newPwd != confirmPwd)
            {
                ShowError("New password and confirmation do not match.");
                return;
            }

            if (newPwd.Length < 8)
            {
                ShowError("New password must be at least 8 characters.");
                return;
            }

            // Cannot reuse same password
            if (currentPwd == newPwd)
            {
                ShowError("New password must be different from your current password.");
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // 1. Verify current password (plaintext — consistent with Login.aspx)
                    const string verifySql = "SELECT std_password FROM student WHERE student_id = @sid";
                    string stored = null;
                    using (var cmd = new SqlCommand(verifySql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        var result = cmd.ExecuteScalar();
                        stored = result?.ToString();
                    }

                    if (stored == null || stored != currentPwd)
                    {
                        ShowError("Current password is incorrect. Please try again.");
                        txtCurrentPassword.Text = "";
                        return;
                    }

                    // 2. Update to new password
                    const string updateSql = @"
                        UPDATE student
                        SET    std_password = @newPwd
                        WHERE  student_id   = @sid";

                    using (var cmd = new SqlCommand(updateSql, con))
                    {
                        cmd.Parameters.AddWithValue("@newPwd", newPwd);
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        int rows = cmd.ExecuteNonQuery();

                        if (rows > 0)
                        {
                            pnlForm.Visible = false;
                            pnlSuccess.Visible = true;
                            pnlError.Visible = false;
                        }
                        else
                        {
                            ShowError("Failed to update password. Please try again.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("An error occurred: " + ex.Message);
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            pnlError.Visible = true;
        }
    }
}