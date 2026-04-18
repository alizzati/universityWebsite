// ================================================================
//  Dashboard.aspx.cs
//  Namespace: UniversitySystem.Pages (sesuai file asal)
//  Perubahan: Tambah SqlConnection untuk load nama student
//             Tambah redirect jika belum login
// ================================================================
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem.Pages
{
    public partial class Dashboard : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // ── Redirect jika belum login ──
            if (Session["StudentId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
                LoadStudentInfo();
        }

        private void LoadStudentInfo()
        {
            int studentId = Convert.ToInt32(Session["StudentId"]);

            // ── ERD: table student ──
            const string sql = "SELECT student_id, std_name, std_email FROM student WHERE student_id = @sid";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string name = dr["std_name"].ToString();
                            string email = dr["std_email"].ToString();

                            // Update session
                            Session["StudentName"] = name;
                            Session["StudentEmail"] = email;

                            // Bind ke label
                            lblName.Text = name.ToUpper();
                            lblFullName.Text = name;
                            lblEmail.Text = email;
                            lblStudentId.Text = studentId.ToString();
                        }
                    }
                }
            }
            catch
            {
                // Fallback ke session
                lblName.Text = Session["StudentName"]?.ToString()?.ToUpper() ?? "STUDENT";
                lblFullName.Text = Session["StudentName"]?.ToString() ?? "Student";
                lblEmail.Text = Session["StudentEmail"]?.ToString() ?? "";
                lblStudentId.Text = studentId.ToString();
            }
        }

        // Logout button (dikekalkan dari file asal)
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }
    }
}