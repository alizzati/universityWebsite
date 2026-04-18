using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

// ═══════════════════════════════════════════════════════════════════════════
//  ERD columns inserted:
//    student(student_id, std_name, std_email, std_password, std_phone, std_address)
//
//  NOTE: Register page was NOT in the original ZIP — this is a new file.
// ═══════════════════════════════════════════════════════════════════════════
namespace payment
{
    public partial class register : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"]?.ConnectionString
            ?? ConfigurationManager.ConnectionStrings["MyDbConn"]?.ConnectionString
            ?? @"Data Source=.\SQLEXPRESS;Initial Catalog=UniversityDB;Integrated Security=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentID"] != null)
            {
                Response.Redirect("~/payment.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string studentId = txtStudentId.Text.Trim();
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();
            string password = txtPassword.Text;
            string confirm = txtConfirm.Text;

            // ── Validation ──
            if (string.IsNullOrEmpty(studentId) || string.IsNullOrEmpty(name) || string.IsNullOrEmpty(password))
            {
                ShowError("Please fill in all required fields (*).");
                return;
            }
            if (password.Length < 8)
            {
                ShowError("Password must be at least 8 characters.");
                return;
            }
            if (password != confirm)
            {
                ShowError("Passwords do not match.");
                return;
            }

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // ── Check duplicate student_id ──
                    using (var chk = new SqlCommand(
                        "SELECT COUNT(*) FROM student WHERE student_id = @sid", con))
                    {
                        chk.Parameters.AddWithValue("@sid", studentId);
                        if ((int)chk.ExecuteScalar() > 0)
                        {
                            ShowError("Student ID already registered. Please use a different ID.");
                            return;
                        }
                    }

                    // ── INSERT using ERD columns ──
                    // ERD: student_id(int PK), std_name, std_email, std_password, std_phone, std_address
                    const string sql = @"
                        INSERT INTO student
                            (student_id, std_name, std_email, std_password, std_phone, std_address)
                        VALUES
                            (@sid, @name, @email, @pwd, @phone, @addr)";

                    using (var cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        cmd.Parameters.AddWithValue("@name", name);
                        cmd.Parameters.AddWithValue("@email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
                        cmd.Parameters.AddWithValue("@pwd", password); // TODO: hash in production
                        cmd.Parameters.AddWithValue("@phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                        cmd.Parameters.AddWithValue("@addr", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address);
                        cmd.ExecuteNonQuery();
                    }
                }

                lblSuccess.Text = "&#10003; Account created! Redirecting to login...";
                lblSuccess.Visible = true;
                Response.AddHeader("Refresh", "2;URL=login.aspx");
            }
            catch (SqlException ex) when (ex.Number == -2 || ex.Number == 2 || ex.Number == 53)
            {
                ShowError("Cannot connect to server. Please try again later.");
            }
            catch (Exception ex)
            {
                ShowError("Registration error: " + ex.Message);
            }
        }

        private void ShowError(string msg) { lblError.Text = msg; lblError.Visible = true; }
    }
}