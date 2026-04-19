using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web;

namespace UniversitySystem
{
    public partial class PaymentHistory : Page
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
                LoadHistory();
            }
        }

        private void LoadHistory()
        {
            // Query untuk mengelompokkan pembayaran berdasarkan waktu transaksi
            const string sql = @"
                SELECT 
                    MAX(payment_id) as payment_id, 
                    created_at_payment as payment_date,
                    bank_name,
                    status_payment as status,
                    SUM(amount_paid) as total_amount,
                    -- Menggabungkan nama mata kuliah dengan pemisah '|'
                    STUFF((SELECT ' | ' + c.course_name 
                           FROM enrollment e2 
                           JOIN course c ON e2.course_id = c.course_id
                           WHERE e2.student_id = e.student_id 
                           AND e2.created_at_enrol = e.created_at_enrol
                           FOR XML PATH('')), 1, 3, '') as courses
                FROM enrollment e
                WHERE student_id = @sid
                GROUP BY created_at_payment, bank_name, status_payment, created_at_enrol
                ORDER BY payment_date DESC";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptPaymentHistory.DataSource = dt;
                        rptPaymentHistory.DataBind();
                        rptPaymentHistory.Visible = true;
                        phNoData.Visible = false;
                    }
                    else
                    {
                        rptPaymentHistory.Visible = false;
                        phNoData.Visible = true;
                    }
                }
            }
            catch
            {
                phNoData.Visible = true;
            }
        }

        protected string GetBadgeClass(string status)
        {
            if (string.IsNullOrEmpty(status)) return "badge-pending";

            switch (status.ToLower())
            {
                case "success": return "badge-success";
                case "pending": return "badge-pending";
                case "failed": return "badge-failed";
                default: return "badge-pending";
            }
        }

        // Method ini harus berada di dalam class PaymentHistory
        protected string FormatCoursesList(object rawObj)
        {
            if (rawObj == null || rawObj == DBNull.Value) return "—";

            string raw = rawObj.ToString();
            var parts = raw.Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries);
            var sb = new System.Text.StringBuilder();

            foreach (var p in parts)
            {
                sb.Append("<span class='c-item'>" + HttpUtility.HtmlEncode(p.Trim()) + "</span>");
            }
            return sb.ToString();
        }
    }
}