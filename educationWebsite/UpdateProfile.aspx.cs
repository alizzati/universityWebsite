// ================================================================
//  UpdateProfile.aspx.cs — COMPLETE
//  Features:
//    1. View profile (labels at top)
//    2. Edit profile form below
//    3. Avatar initials from name
//    4. Stats: active courses, credits, payments
//  ERD: student(student_id, std_name, std_email, std_password,
//               std_phone, std_address)
// ================================================================
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class UpdateProfile : Page
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
                LoadProfile();
                LoadStats();
            }
        }

        // ── Load profile data into both view labels and edit form ────────
        private void LoadProfile()
        {
            const string sql = @"
                SELECT student_id, std_name, std_email,
                       ISNULL(std_phone,   '')   AS std_phone,
                       ISNULL(std_address, '')   AS std_address
                FROM   student
                WHERE  student_id = @sid";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            string name = dr["std_name"].ToString();
                            string email = dr["std_email"].ToString();
                            string phone = dr["std_phone"].ToString();
                            string address = dr["std_address"].ToString();
                            string id = dr["student_id"].ToString();

                            // Hero section
                            lblHeroName.Text = name;
                            lblHeroId.Text = id;
                            lblHeroEmail.Text = email;
                            lblAvatarInitials.Text = GetInitials(name);

                            // View labels
                            lblViewId.Text = id;
                            lblViewName.Text = name;
                            lblViewEmail.Text = email;
                            lblViewPhone.Text = string.IsNullOrEmpty(phone) ? "—" : phone;
                            lblViewAddress.Text = string.IsNullOrEmpty(address) ? "—" : address;

                            // Edit form pre-fill
                            txtStudentId.Text = id;
                            txtName.Text = name;
                            txtEmail.Text = email;
                            txtPhone.Text = phone;
                            txtAddress.Text = address;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Failed to load profile: " + ex.Message);
            }
        }

        // ── Load statistics (courses, credits, payments) ─────────────────
        private void LoadStats()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Active courses
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM enrollment WHERE student_id=@sid AND enrol_status='Active'", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        lblStatCourses.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Total credits of active courses
                    using (var cmd = new SqlCommand(
                        @"SELECT ISNULL(SUM(c.credits),0)
                          FROM enrollment e
                          JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20))
                          WHERE e.student_id=@sid AND e.enrol_status='Active'", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        lblStatCredits.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Total successful payments
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM payment WHERE student_id=@sid AND status='Success'", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        lblStatPayments.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            catch { }
        }

        // ── Save updated profile ─────────────────────────────────────────
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();

            const string sql = @"
                UPDATE student
                SET    std_name    = @name,
                       std_email   = @email,
                       std_phone   = @phone,
                       std_address = @address
                WHERE  student_id  = @sid";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                    cmd.Parameters.AddWithValue("@address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address);
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    int rows = cmd.ExecuteNonQuery();

                    if (rows > 0)
                    {
                        // Update session
                        Session["StudentName"] = name;
                        Session["StudentEmail"] = email;

                        pnlSuccess.Visible = true;
                        pnlError.Visible = false;

                        // Refresh view labels
                        LoadProfile();
                        LoadStats();
                    }
                    else
                    {
                        ShowError("No changes were saved.");
                    }
                }
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                ShowError("This email address is already registered to another account.");
            }
            catch (Exception ex)
            {
                ShowError("An error occurred: " + ex.Message);
            }
        }

        // ── Helpers ──────────────────────────────────────────────────────
        private static string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "S";
            var parts = fullName.Trim().Split(new[] { ' ' }, System.StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }
    }
}