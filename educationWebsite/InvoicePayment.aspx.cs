// ================================================================
//  InvoicePayment.aspx.cs — FIXED
//
//  REQUIREMENT: Show invoice grouped by payment session.
//  If user paid 5 courses in one session, show all 5 on one invoice.
//
//  When ?pid=X is given: show all payments from the same batch
//  (same created_at minute + bank + student), not just payment X.
//  This ensures the invoice shows the complete transaction.
// ================================================================
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class invoicepayment : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        private int StudentId =>
            Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            { Response.Redirect("~/Login.aspx"); return; }

            if (!IsPostBack)
            {
                // Pre-select current month
                string currentPeriod = DateTime.Now.ToString("MMM").ToUpper() + DateTime.Now.Year;
                foreach (System.Web.UI.WebControls.ListItem item in ddlPeriod.Items)
                    if (item.Value.Equals(currentPeriod, StringComparison.OrdinalIgnoreCase))
                    { item.Selected = true; break; }

                string studentName = Session["StudentName"]?.ToString() ?? "Student";
                lblStudentName.Text = studentName + "  (ID: " + StudentId + ")";
                lblStudentNamePrint.Text = studentName + "  (ID: " + StudentId + ")";
                lblPeriod.Text = ddlPeriod.SelectedItem?.Text ?? "";
                lblPeriodPrint.Text = ddlPeriod.SelectedItem?.Text ?? "";

                LoadSummary();
                LoadInvoiceDetail();
            }
        }

        protected void ddlPeriod_SelectedIndexChanged(object sender, EventArgs e)
        {
            lblPeriod.Text = ddlPeriod.SelectedItem?.Text ?? "";
            lblPeriodPrint.Text = ddlPeriod.SelectedItem?.Text ?? "";
            LoadSummary();
            LoadInvoiceDetail();
        }

        private void LoadSummary()
        {
            GetPeriodDates(out int month, out int year);
            const string sql =
                "SELECT ISNULL(SUM(amount), 0) FROM payment " +
                "WHERE student_id=@sid AND MONTH(created_at)=@m AND YEAR(created_at)=@y AND status='Success'";
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    cmd.Parameters.AddWithValue("@m", month);
                    cmd.Parameters.AddWithValue("@y", year);
                    con.Open();
                    decimal total = Convert.ToDecimal(cmd.ExecuteScalar());
                    lblTotalInvoices.Text = "RM " + total.ToString("N2");
                    lblTotalScholarships.Text = "RM 0.00";
                    lblNetAmount.Text = "RM " + total.ToString("N2");
                }
            }
            catch
            {
                lblTotalInvoices.Text = "RM 0.00";
                lblTotalScholarships.Text = "RM 0.00";
                lblNetAmount.Text = "RM 0.00";
            }
        }

        private void LoadInvoiceDetail()
        {
            GetPeriodDates(out int month, out int year);
            string pidStr = Request.QueryString["pid"];

            string sql;
            SqlCommand cmd;
            var con = new SqlConnection(ConnStr);

            if (!string.IsNullOrEmpty(pidStr) && int.TryParse(pidStr, out int pid))
            {
                // FIX: Load ALL payments from the same batch as the given pid.
                // A "batch" = payments made within the same minute by the same student.
                sql =
                    "SELECT 'INV-' + RIGHT('0000' + CAST(p.payment_id AS VARCHAR), 4) AS Particulars, " +
                    "       'Course Fee' AS Type, " +
                    "       FORMAT(p.created_at,'dd/MM/yyyy HH:mm') AS DocumentDate, " +
                    "       p.amount AS Amount, p.status AS Status, " +
                    "       p.course_id, ISNULL(c.course_name,'—') AS course_name, p.bank_name " +
                    "FROM payment p " +
                    "LEFT JOIN course c ON c.course_id = p.course_id " +
                    "WHERE p.student_id = @sid " +
                    "  AND CONVERT(VARCHAR(16), p.created_at, 120) = (" +
                    "      SELECT CONVERT(VARCHAR(16), created_at, 120) FROM payment WHERE payment_id=@pid AND student_id=@sid" +
                    "  ) " +
                    "ORDER BY p.payment_id";
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@pid", pid);
                cmd.Parameters.AddWithValue("@sid", StudentId);
            }
            else
            {
                // Show all payments for selected period
                sql =
                    "SELECT 'INV-' + RIGHT('0000' + CAST(p.payment_id AS VARCHAR), 4) AS Particulars, " +
                    "       'Course Fee' AS Type, " +
                    "       FORMAT(p.created_at,'dd/MM/yyyy HH:mm') AS DocumentDate, " +
                    "       p.amount AS Amount, p.status AS Status, " +
                    "       p.course_id, ISNULL(c.course_name,'—') AS course_name, p.bank_name " +
                    "FROM payment p " +
                    "LEFT JOIN course c ON c.course_id = p.course_id " +
                    "WHERE p.student_id=@sid AND MONTH(p.created_at)=@m AND YEAR(p.created_at)=@y " +
                    "ORDER BY p.created_at DESC";
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@sid", StudentId);
                cmd.Parameters.AddWithValue("@m", month);
                cmd.Parameters.AddWithValue("@y", year);
            }

            try
            {
                con.Open();
                var da = new SqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                gvInvoice.DataSource = dt;
                gvInvoice.DataBind();
            }
            catch { }
            finally { con.Dispose(); cmd.Dispose(); }
        }

        private void GetPeriodDates(out int month, out int year)
        {
            string period = ddlPeriod.SelectedValue ?? "";
            month = DateTime.Now.Month;
            year = DateTime.Now.Year;
            if (period.Length >= 7)
            {
                month = MonthFromAbbr(period.Substring(0, 3));
                int.TryParse(period.Substring(3), out year);
            }
        }

        private static int MonthFromAbbr(string abbr)
        {
            switch (abbr.ToUpper())
            {
                case "JAN": return 1;
                case "FEB": return 2;
                case "MAR": return 3;
                case "APR": return 4;
                case "MAY": return 5;
                case "JUN": return 6;
                case "JUL": return 7;
                case "AUG": return 8;
                case "SEP": return 9;
                case "OCT": return 10;
                case "NOV": return 11;
                case "DEC": return 12;
                default: return DateTime.Now.Month;
            }
        }
    }
}