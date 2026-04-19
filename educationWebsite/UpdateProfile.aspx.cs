// ================================================================
//  UpdateProfile.aspx.cs
//
//  ALUR KERJA:
//  1. Page_Load → cek session login
//  2. LoadProfile() → baca dari DB, isi labels View + form fields
//  3. LoadStats()   → hitung courses/credits/payments
//  4. btnUpdate_Click → validasi → UPDATE DB → refresh labels
//
//  LOGIKA:
//  - Labels (lblView*) = display read-only di atas
//  - TextBox (txt*)    = form edit di bawah, pre-filled dari DB
//  - Setelah save: session diupdate, labels di-refresh
//
//  ERD: student(student_id INT PK, std_name, std_email,
//               std_password, std_phone, std_address)
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

        // ── 1. Page Load ─────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            // Only load on first visit, not on postback (button click)
            if (!IsPostBack)
            {
                LoadProfile();
                LoadStats();
            }
        }

        // ── 2. Read profile from DB ───────────────────────────────────────
        private void LoadProfile()
        {
            const string sql = @"
                SELECT student_id,
                       std_name,
                       std_email,
                       ISNULL(std_phone,   '') AS std_phone,
                       ISNULL(std_address, '') AS std_address
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
                            string id = dr["student_id"].ToString();
                            string name = dr["std_name"].ToString();
                            string email = dr["std_email"].ToString();
                            string phone = dr["std_phone"].ToString();
                            string address = dr["std_address"].ToString();

                            // Hero labels (top header)
                            lblInitials.Text = GetInitials(name);
                            lblHeroName.Text = name;
                            lblHeroId.Text = id;
                            lblHeroEmail.Text = email;

                            // Read-only view labels
                            lblViewId.Text = id;
                            lblViewName.Text = name;
                            lblViewEmail.Text = email;
                            lblViewPhone.Text = string.IsNullOrEmpty(phone) ? "—" : phone;
                            lblViewAddress.Text = string.IsNullOrEmpty(address) ? "—" : address;

                            // Edit form — pre-fill fields
                            txtStudentId.Text = id;
                            txtName.Text = name;
                            txtEmail.Text = email;
                            txtPhone.Text = phone;
                            txtAddress.Text = address;
                        }
                        else
                        {
                            ShowError("Student record not found.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Failed to load profile: " + ex.Message);
            }
        }

        // ── 3. Load statistics ────────────────────────────────────────────
        private void LoadStats()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Count active enrollments
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM enrollment WHERE student_id=@sid AND enrol_status='Active'", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        lblStatCourses.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Sum credits of active courses
                    using (var cmd = new SqlCommand(
                        @"SELECT ISNULL(SUM(c.credits),0)
                          FROM enrollment e
                          JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20))
                          WHERE e.student_id=@sid AND e.enrol_status='Active'", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        lblStatCredits.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Count successful payments
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM payment WHERE student_id=@sid AND status='Success'", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        lblStatPaid.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            catch { /* stats non-critical, silently ignore */ }
        }

        // ── 4. Save updated profile ───────────────────────────────────────
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();

            if (string.IsNullOrEmpty(name)) { ShowError("Name cannot be empty."); return; }
            if (string.IsNullOrEmpty(email)) { ShowError("Email cannot be empty."); return; }

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
                    cmd.Parameters.AddWithValue("@phone", (object)phone ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@address", (object)address ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();

                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                    {
                        // Update session so NavBar shows new name
                        Session["StudentName"] = name;
                        Session["StudentEmail"] = email;

                        pnlSuccess.Visible = true;
                        pnlError.Visible = false;

                        // Refresh all display labels after save
                        LoadProfile();
                        LoadStats();
                    }
                    else
                    {
                        ShowError("Update failed — no rows changed.");
                    }
                }
            }
            catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
            {
                ShowError("That email is already used by another account.");
            }
            catch (Exception ex)
            {
                ShowError("Error: " + ex.Message);
            }
        }

        // ── Helpers ───────────────────────────────────────────────────────
        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "S";
            var parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0][0].ToString().ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }
    }
}