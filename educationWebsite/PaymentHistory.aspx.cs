using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
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
                    string pid = Request.QueryString["pid"];
                    if (!string.IsNullOrEmpty(pid))
                        lblPaidNotice.Text = "&#10003; Payment successful! " +
                            "<a href='InvoicePayment.aspx?pid=" + pid + "' style='font-weight:700'>View Invoice</a>";
                }

                BindPaymentHistory();
            }
        }

        private void BindPaymentHistory()
        {
            const string sql = @"
            SELECT 
                MIN(p.payment_id)   AS batch_id, 
                MIN(p.created_at)   AS created_at, 
                ISNULL(MIN(p.bank_name), 'Online') AS bank_name, 
                p.status, 
                SUM(p.amount)       AS total_amount, 
                STUFF((
                    SELECT ';;' + ISNULL(c2.course_code, '') + '|' + ISNULL(c2.course_name, '—')
                    FROM payment p2
                    LEFT JOIN course c2 ON c2.course_id = p2.course_id
                    WHERE p2.student_id = p.student_id
                      AND p2.status    = p.status
                      AND CAST(p2.created_at AS DATE) = CAST(p.created_at AS DATE)
                    FOR XML PATH('')), 1, 2, '') AS courses_list
            FROM payment p
            WHERE p.student_id = @sid
            GROUP BY p.status, CAST(p.created_at AS DATE), p.student_id
            ORDER BY MIN(p.created_at) DESC";

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

        // Dipanggil dari ASPX: <%# FormatCoursesList(Eval("courses_list")) %>
        // Format courses_list: "CS101|Intro to CS;;MATH2|Calculus II"
        // → render sebagai badge HTML untuk tiap course
        protected string FormatCoursesList(object coursesListObj)
        {
            if (coursesListObj == null || coursesListObj == DBNull.Value)
                return "<span class='c-item'>—</span>";

            string coursesList = coursesListObj.ToString();
            if (string.IsNullOrEmpty(coursesList))
                return "<span class='c-item'>—</span>";

            var sb = new StringBuilder();
            string[] courses = coursesList.Split(new[] { ";;" }, StringSplitOptions.RemoveEmptyEntries);

            foreach (string course in courses)
            {
                string[] parts = course.Split(new[] { '|' }, 2);
                string code = parts.Length > 0 ? System.Web.HttpUtility.HtmlEncode(parts[0].Trim()) : "—";
                string name = parts.Length > 1 ? System.Web.HttpUtility.HtmlEncode(parts[1].Trim()) : "";

                if (!string.IsNullOrEmpty(name))
                    sb.AppendFormat("<span class='c-item' title='{1}'>{0}</span>", code, name);
                else
                    sb.AppendFormat("<span class='c-item'>{0}</span>", code);
            }

            return sb.ToString();
        }

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