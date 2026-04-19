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
            { Response.Redirect("~/Login.aspx"); return; }
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
                        "SELECT student_id, std_name, std_email FROM student WHERE student_id=@sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        using (var dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                lblStudentId.Text = dr["student_id"].ToString();
                                lblStudentName.Text = dr["std_name"].ToString();
                                lblEmail.Text = dr["std_email"].ToString();
                            }
                        }
                    }

                    lblStatementId.Text = DateTime.Now.ToString("yyyyMMdd") + "-" + studentId.ToString("D5");
                    lblStatementDate.Text = DateTime.Now.ToString("dd MMMM yyyy");

                    // Enrolled courses — FIX: CAST course_id for JOIN
                    const string courseQuery =
                        "SELECT c.course_id   AS course_code, " +
                        "       c.course_name, " +
                        "       ISNULL(c.credits, 0) AS credits, " +
                        "       (ISNULL(c.credits, 0) * 150) AS amount " +
                        "FROM   enrollment e " +
                        "JOIN   course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                        "WHERE  e.student_id = @sid AND e.enrol_status = 'Active' " +
                        "ORDER  BY c.course_id";

                    using (var cmd = new SqlCommand(courseQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);
                        gvCourses.DataSource = dt;
                        gvCourses.DataBind();
                    }

                    // Payment history — FIX: include bank_name, formatted reference
                    const string payQuery =
                        "SELECT created_at AS payment_date, " +
                        "       'INV-' + RIGHT('0000' + CAST(payment_id AS VARCHAR), 4) AS reference_no, " +
                        "       'Course Fee — ' + ISNULL(course_id, '') AS description, " +
                        "       ISNULL(bank_name, 'Online') AS bank_name, " +
                        "       amount, status " +
                        "FROM   payment " +
                        "WHERE  student_id = @sid " +
                        "ORDER  BY created_at DESC";

                    using (var cmd = new SqlCommand(payQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var da = new SqlDataAdapter(cmd);
                        var dt = new DataTable();
                        da.Fill(dt);
                        gvPayments.DataSource = dt;
                        gvPayments.DataBind();
                    }

                    // Outstanding balance = total course fees - total paid
                    const string balQuery =
                        "SELECT " +
                        "    ISNULL((SELECT SUM(ISNULL(c2.credits,0)*150) " +
                        "            FROM enrollment e2 " +
                        "            JOIN course c2 ON c2.course_id = CAST(e2.course_id AS VARCHAR(20)) " +
                        "            WHERE e2.student_id=@sid AND e2.enrol_status='Active'), 0) " +
                        "  - ISNULL((SELECT SUM(amount) FROM payment " +
                        "            WHERE student_id=@sid AND status='Success'), 0) " +
                        "    AS outstanding";

                    using (var cmd = new SqlCommand(balQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentId);
                        var result = cmd.ExecuteScalar();
                        decimal outstanding = (result != null && result != DBNull.Value)
                            ? Convert.ToDecimal(result) : 0;
                        lblTotalBalance.Text = (outstanding < 0 ? 0 : outstanding).ToString("N2");
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

        // Download as plain text (fallback if window.print() not preferred)
        protected void btnDownloadPDF_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.ContentType = "text/plain";
            Response.AddHeader("Content-Disposition",
                "attachment; filename=Statement_" + lblStudentId.Text + ".txt");

            var sb = new StringBuilder();
            sb.AppendLine("UNISYS UNIVERSITY — STUDENT FINANCIAL STATEMENT");
            sb.AppendLine("================================================");
            sb.AppendLine("Statement Ref : " + lblStatementId.Text);
            sb.AppendLine("Date          : " + lblStatementDate.Text);
            sb.AppendLine();
            sb.AppendLine("Student Name  : " + lblStudentName.Text);
            sb.AppendLine("Student ID    : " + lblStudentId.Text);
            sb.AppendLine("Email         : " + lblEmail.Text);
            sb.AppendLine();
            sb.AppendLine("Outstanding Balance: RM " + lblTotalBalance.Text);
            sb.AppendLine();
            sb.AppendLine("(For a formatted PDF, use the Download/Print button on the statement page.)");

            Response.Write(sb.ToString());
            Response.End();
        }
    }
}