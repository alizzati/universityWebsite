// ================================================================
//  PaymentHistory.aspx.cs — FIXED
//  FIX 1: Namespace = UniversitySystem (was payment.historypayment)
//  FIX 2: Session["StudentId"] int (was Session["StudentID"] string)
//  FIX 3: payment.student_id = INT query
//  FIX 4: Show invoice link per payment row
//  FIX 5: View invoice button for specific payment
// ================================================================
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

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
            { Response.Redirect("~/Login.aspx"); return; }

            if (!IsPostBack)
            {
                if (Request.QueryString["paid"] == "1")
                {
                    lblPaidNotice.Visible = true;

                    // Show invoice link if payment_id provided
                    string pid = Request.QueryString["pid"];
                    if (!string.IsNullOrEmpty(pid))
                        lblPaidNotice.Text = "&#10003; Payment successful! " +
                            "<a href='invoicepayment.aspx?pid=" + pid + "' style='font-weight:700'>View Invoice</a>";
                }

                BindPaymentHistory();
            }
        }

        private void BindPaymentHistory()
        {
            // ERD: payment(payment_id INT PK, student_id INT FK, course_id VARCHAR FK,
            //               bank_name, amount INT, status, created_at)
            const string sql = @"
                SELECT
                    p.payment_id,
                    p.created_at,
                    p.amount,
                    p.status,
                    p.bank_name,
                    p.course_id,
                    ISNULL(c.course_name, '—') AS course_name
                FROM   payment p
                LEFT   JOIN course c ON c.course_id = p.course_id
                WHERE  p.student_id = @sid
                ORDER  BY p.created_at DESC";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 15;
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();

                    var da = new SqlDataAdapter(cmd);
                    var dt = new DataTable();
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
            catch (SqlException ex) when (ex.Number == -2 || ex.Number == 2 || ex.Number == 53)
            {
                Response.Redirect("~/Login.aspx?reason=timeout", false);
            }
            catch (Exception ex)
            {
                phNoData.Visible = true;
                phNoData.Controls.Add(new System.Web.UI.LiteralControl(
                    "<div style='color:#C0001D;padding:1.5rem;font-size:.85rem'>Error: " + ex.Message + "</div>"));
            }
        }

        // Helper called from ASPX inline
        protected string GetBadgeClass(string status)
        {
            switch (status?.ToLower())
            {
                case "success": return "badge-success";
                case "pending": return "badge-pending";
                case "failed": return "badge-failed";
                default: return "badge-pending";
            }
        }
    }
}