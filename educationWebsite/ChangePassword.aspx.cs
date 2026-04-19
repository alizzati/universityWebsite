// ================================================================
//  ChangePassword.aspx.cs
//
//  ALUR KERJA:
//  1. Page_Load → cek session, tidak ada loading data (tidak perlu)
//  2. btnChange_Click:
//     a. Validasi form (ASP.NET validators + server-side)
//     b. Baca password lama dari DB
//     c. Bandingkan dengan input current password (plaintext)
//     d. Cek password baru ≠ password lama
//     e. UPDATE student SET std_password = @newPwd
//     f. Sembunyikan form, tampilkan success screen
//
//  LOGIKA PASSWORD:
//  - Sistem ini menyimpan password sebagai PLAINTEXT
//    (konsisten dengan Login.aspx yang juga plaintext compare)
//  - JANGAN hash di sini jika Login tidak hash — harus konsisten
//
//  ERD: student(student_id INT PK, std_password varchar, ...)
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
            // No data to load on GET — form is empty by design
        }

        protected void btnChange_Click(object sender, EventArgs e)
        {
            // ASP.NET validators handle client-side. We re-check server-side too.
            if (!Page.IsValid) return;

            // Read raw values — NEVER trim passwords
            string currentPwd = txtCurrent.Text;
            string newPwd = txtNew.Text;
            string confirmPwd = txtConfirm.Text;

            // ── Server-side validation ───────────────────────────────────
            if (string.IsNullOrEmpty(currentPwd))
            {
                ShowError("Please enter your current password.");
                return;
            }

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

                    // ── Step 1: Verify current password ─────────────────
                    string stored = null;
                    using (var cmd = new SqlCommand(
                        "SELECT std_password FROM student WHERE student_id = @sid", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        var result = cmd.ExecuteScalar();
                        stored = result?.ToString();
                    }

                    if (stored == null)
                    {
                        ShowError("Student account not found.");
                        return;
                    }

                    // Plaintext comparison — consistent with Login.aspx
                    if (stored != currentPwd)
                    {
                        ShowError("Current password is incorrect. Please try again.");
                        txtCurrent.Text = ""; // clear wrong password field
                        return;
                    }

                    // ── Step 2: Update to new password ───────────────────
                    using (var cmd = new SqlCommand(
                        "UPDATE student SET std_password = @newPwd WHERE student_id = @sid", con))
                    {
                        cmd.Parameters.AddWithValue("@newPwd", newPwd);
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        int rows = cmd.ExecuteNonQuery();

                        if (rows > 0)
                        {
                            // Hide form, show success screen
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