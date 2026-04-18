// ================================================================
//  StudentStatement.aspx.cs — FIXED
//  FIX 1: course JOIN uses CAST(e.course_id AS VARCHAR(20)) = c.course_id
//         (enrollment.course_id is INT, course.course_id is VARCHAR per ERD)
//  FIX 2: payment.student_id is INT — consistent query
//  No other changes (logic was correct)
// ================================================================
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class StudentStatement : Page
    {
        private string connectionString =
            System.Configuration.ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }
            if (!IsPostBack) LoadStatementData();
        }

        private void LoadStatementData()
        {
            int studentId = Convert.ToInt32(Session["StudentId"]);
            try
            {
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Student info
                    using (var cmd = new SqlCommand(
                        "SELECT student_id, std_name, std_email FROM student WHERE student_id = @sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        using (var dr = cmd.ExecuteReader())
                            if (dr.Read())
                            {
                                lblStudentId.Text = dr["student_id"].ToString();
                                lblStudentName.Text = dr["std_name"].ToString();
                                lblEmail.Text = dr["std_email"].ToString();
                            }
                    }

                    lblStatementId.Text = DateTime.Now.ToString("yyyyMMdd") + "-" + studentId.ToString("D5");
                    lblStatementDate.Text = DateTime.Now.ToString("dd MMMM yyyy");

                    // FIX: CAST enrollment.course_id AS VARCHAR to join with course.course_id VARCHAR
                    const string courseQuery = @"
                        SELECT
                            c.course_id   AS course_code,
                            c.course_name,
                            c.credits,
                            (c.credits * 150) AS amount
                        FROM   enrollment e
                        JOIN   course c ON c.course_id = CAST(e.course_id AS VARCHAR(20))
                        WHERE  e.student_id   = @sid
                          AND  e.enrol_status = 'Active'";

                    using (var cmd = new SqlCommand(courseQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);
                        gvCourses.DataSource = dt;
                        gvCourses.DataBind();
                    }

                    // Payment history — student_id INT per ERD
                    const string payQuery = @"
                        SELECT
                            created_at AS payment_date,
                            payment_id AS reference_no,
                            'Course Payment - ' + ISNULL(bank_name, 'Online') AS description,
                            amount,
                            status
                        FROM   payment
                        WHERE  student_id = @sid
                        ORDER  BY created_at DESC";

                    using (var cmd = new SqlCommand(payQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);
                        gvPayments.DataSource = dt;
                        gvPayments.DataBind();
                    }

                    // Outstanding balance (enrolled courses minus payments)
                    const string balQuery = @"
                        SELECT
                            ISNULL(SUM(c.credits * 150), 0) -
                            ISNULL((SELECT SUM(amount) FROM payment
                                    WHERE student_id = @sid AND status IN ('Success','Paid')), 0)
                            AS outstanding
                        FROM   enrollment e
                        JOIN   course c ON c.course_id = CAST(e.course_id AS VARCHAR(20))
                        WHERE  e.student_id = @sid AND e.enrol_status = 'Active'";

                    using (var cmd = new SqlCommand(balQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var result = cmd.ExecuteScalar();
                        decimal outstanding = result != null && result != DBNull.Value ? Convert.ToDecimal(result) : 0;
                        lblTotalBalance.Text = outstanding < 0 ? "0.00" : outstanding.ToString("N2");
                    }
                }
            }
            catch (Exception ex)
            {
                pnlStatement.Visible = false;
                pnlError.Visible = true;
                lblError.Text = "Error loading statement: " + ex.Message;
            }
        }

        protected void btnDownloadPDF_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.ContentType = "text/plain";
            Response.AddHeader("Content-Disposition", "attachment; filename=Statement_" + lblStudentId.Text + ".txt");

            var sb = new StringBuilder();
            sb.AppendLine("UNIVERSITY SYSTEM - STUDENT STATEMENT");
            sb.AppendLine("=====================================");
            sb.AppendLine("Student : " + lblStudentName.Text);
            sb.AppendLine("ID      : " + lblStudentId.Text);
            sb.AppendLine("Email   : " + lblEmail.Text);
            sb.AppendLine("Date    : " + lblStatementDate.Text);
            sb.AppendLine();
            sb.AppendLine("Total Outstanding: RM " + lblTotalBalance.Text);

            Response.Write(sb.ToString());
            Response.End();
        }
    }
}