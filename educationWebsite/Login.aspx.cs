using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class login : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"]?.ConnectionString
            ?? ConfigurationManager.ConnectionStrings["MyDbConn"]?.ConnectionString
            ?? @"Data Source=.\SQLEXPRESS;Initial Catalog=UniversityDB;Integrated Security=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Already logged in → go to dashboard
            if (Session["StudentID"] != null)
            {
                Response.Redirect("~/dashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                string reason = Request.QueryString["reason"];
                if (reason == "session") pnlSessionNotice.Visible = true;
                else if (reason == "timeout") pnlTimeoutNotice.Visible = true;
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string studentId = txtStudentId.Text.Trim();
            string password = txtPassword.Text;   // do NOT trim passwords

            if (string.IsNullOrEmpty(studentId) || string.IsNullOrEmpty(password))
            {
                ShowMsg("Please fill in your Student ID and password.", isError: true);
                return;
            }

            try
            {
                // ── ERD: student(student_id, std_name, std_password) ──
                const string sql = @"
                    SELECT student_id, std_name
                    FROM   student
                    WHERE  student_id = @sid
                      AND  std_password = @pwd";

                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 15;
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    cmd.Parameters.AddWithValue("@pwd", password);
                    con.Open();

                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            Session["StudentID"] = dr["student_id"].ToString();
                            Session["StudentName"] = dr["std_name"].ToString();

                            string returnUrl = Request.QueryString["ReturnUrl"];
                            Response.Redirect(
                                !string.IsNullOrEmpty(returnUrl) ? returnUrl : "~/dashboard.aspx",
                                false);
                            Context.ApplicationInstance.CompleteRequest();
                        }
                        else
                        {
                            ShowMsg("Incorrect Student ID or password. Please try again.", isError: true);
                        }
                    }
                }
            }
            catch (SqlException ex) when (IsConnError(ex))
            {
                pnlTimeoutNotice.Visible = true;
                ShowMsg("Cannot connect to server. Please try again later.", isError: true);
            }
            catch (Exception ex)
            {
                ShowMsg("Login error: " + ex.Message, isError: true);
            }
        }

        private static bool IsConnError(SqlException ex) =>
            ex.Number == -2 || ex.Number == 2 || ex.Number == 53 ||
            ex.Message.IndexOf("timeout", StringComparison.OrdinalIgnoreCase) >= 0 ||
            ex.Message.IndexOf("pre-login", StringComparison.OrdinalIgnoreCase) >= 0;

        private void ShowMsg(string msg, bool isError)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = isError ? "alert-block alert-error" : "alert-block alert-success";
            lblMessage.Visible = true;
        }
    }
}