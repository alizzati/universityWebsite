// ================================================================
//  OnlinePayment.aspx.cs — FULLY FIXED
//
//  BUG 1 — "Loading stuck after confirm":
//    Root cause: JS onclick hid pnlPaymentForm and showed pnlProcessing
//    BEFORE the postback completed. When the server response arrived,
//    the ASP.NET page rendered with pnlSuccess=true but then the
//    window.load event fired the pageLoader animation again, which
//    covered the success panel.
//
//    Fix: Removed JS panel manipulation. Added hfPaymentDone HiddenField.
//    Server sets it to "1" on success. JS reads it on DOMContentLoaded
//    (not window.load) and hides the processing overlay immediately.
//
//  BUG 2 — ViewState["PaymentCourses"] empty on postback:
//    Root cause: ViewState was only written inside LoadCourseItems()
//    which only runs on !IsPostBack. On postback, the query string is
//    gone, so the fallback "string.Join(',', CourseIds)" returns "".
//
//    Fix: Save ViewState["PaymentCourses"] on Page_Load (not IsPostBack)
//    using CourseIds from query string.
//
//  BUG 3 — Enrollment status not synced:
//    Fix: After payment INSERT, UPDATE enrollment SET enrol_status='Active'
//    for both 'Pending Payment' and 'Pending' (covers edge cases).
// ================================================================
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace UniversitySystem
{
    public partial class OnlinePayment : Page
    {
        private const int FeePerCredit = 150;

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        private int StudentId =>
            Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;

        private string[] CourseIds
        {
            get
            {
                string raw = Request.QueryString["courses"];
                if (string.IsNullOrEmpty(raw)) return new string[0];
                return raw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            { Response.Redirect("~/Login.aspx?reason=session"); return; }

            // FIX: Always capture CourseIds from query string into ViewState
            // so it's available when btnSubmit_Click fires (postback loses query string)
            string[] qs = CourseIds;
            if (qs.Length > 0)
                ViewState["PaymentCourses"] = string.Join(",", qs);

            if (!IsPostBack)
            {
                hfPaymentDone.Value = "0";
                txtStudentId.Text = StudentId.ToString();
                pnlPaymentForm.Visible = true;
                pnlSuccess.Visible = false;

                LoadCourseItems();
                SetupVA();
            }
        }

        // ── Load course fee table ─────────────────────────────────────────
        private void LoadCourseItems()
        {
            // Use ViewState first (already saved above), then query string
            string coursesStr = ViewState["PaymentCourses"]?.ToString()
                             ?? string.Join(",", CourseIds);
            string[] ids = coursesStr.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            if (ids.Length == 0) { LoadAllPendingCourses(); return; }

            var list = new List<CourseItem>();
            decimal total = 0;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    foreach (string cid in ids)
                    {
                        using (var cmd = new SqlCommand(
                            "SELECT course_id, course_name, ISNULL(credits,3) AS credits " +
                            "FROM course WHERE course_id = @cid", con))
                        {
                            cmd.Parameters.AddWithValue("@cid", cid.Trim());
                            using (var dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    int credits = Convert.ToInt32(dr["credits"]);
                                    decimal fee = credits * FeePerCredit;
                                    total += fee;
                                    list.Add(new CourseItem
                                    {
                                        CourseId = dr["course_id"].ToString(),
                                        CourseName = dr["course_name"].ToString(),
                                        Credits = credits,
                                        Fee = fee,
                                        FeeFormatted = "RM " + fee.ToString("N2")
                                    });
                                }
                            }
                        }
                    }
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Error loading courses: " + ex.Message); return; }

            if (list.Count == 0)
            { ShowError("No valid courses found. Please go back and select courses again."); return; }

            rptCourseItems.DataSource = list;
            rptCourseItems.DataBind();
            lblGrandTotal.Text = total.ToString("N2");
            hfGrandTotal.Value = total.ToString("N2");
            ViewState["PaymentTotal"] = total;
        }

        private void LoadAllPendingCourses()
        {
            const string sql =
                "SELECT c.course_id, c.course_name, ISNULL(c.credits,3) AS credits " +
                "FROM enrollment e " +
                "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                "WHERE e.student_id=@sid AND e.enrol_status='Pending Payment' " +
                "ORDER BY c.course_id";

            var list = new List<CourseItem>();
            decimal total = 0;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            int credits = Convert.ToInt32(dr["credits"]);
                            decimal fee = credits * FeePerCredit;
                            total += fee;
                            list.Add(new CourseItem
                            {
                                CourseId = dr["course_id"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Credits = credits,
                                Fee = fee,
                                FeeFormatted = "RM " + fee.ToString("N2")
                            });
                        }
                    }
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Error: " + ex.Message); return; }

            if (list.Count == 0)
            {
                ShowError("No pending courses to pay. <a href='OnlineEnrollment.aspx'>Enrol first.</a>");
                btnSubmit.Enabled = false;
                return;
            }

            rptCourseItems.DataSource = list;
            rptCourseItems.DataBind();
            lblGrandTotal.Text = total.ToString("N2");
            hfGrandTotal.Value = total.ToString("N2");

            ViewState["PaymentTotal"] = total;
            var cids = new List<string>();
            foreach (var ci in list) cids.Add(ci.CourseId);
            ViewState["PaymentCourses"] = string.Join(",", cids);
        }

        private void SetupVA()
        {
            pnlVA.Visible = true;
            lblVABank.Text = "Maybank2u";
            lblVANumber.Text = GenerateVA(StudentId);
            lblVAAmount.Text = hfGrandTotal.Value;
        }

        private static string GenerateVA(int studentId)
        {
            string sid = studentId.ToString().PadLeft(6, '0');
            string day = DateTime.Today.DayOfYear.ToString().PadLeft(3, '0');
            return "1234" + sid + day;
        }

        // ── CONFIRM PAYMENT ───────────────────────────────────────────────
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string bank = rbMaybank.Checked ? "Maybank2u"
                        : rbCimb.Checked ? "CIMB Clicks"
                        : rbPublic.Checked ? "Public Bank"
                        : rbRhb.Checked ? "RHB Online"
                        : "Maybank2u";

            // FIX: Read from ViewState (query string is gone on postback)
            decimal total = ViewState["PaymentTotal"] != null
                                    ? (decimal)ViewState["PaymentTotal"] : 0;
            string coursesStr = ViewState["PaymentCourses"]?.ToString() ?? "";

            string[] courseIds = coursesStr.Split(
                new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            // Fallback: if ViewState lost, re-query pending courses for this student
            if (courseIds.Length == 0)
            {
                try
                {
                    var tmpList = new List<string>();
                    using (var con2 = new SqlConnection(ConnStr))
                    {
                        con2.Open();
                        using (var c2 = new SqlCommand(
                            "SELECT CAST(e.course_id AS VARCHAR(20)) " +
                            "FROM enrollment e WHERE e.student_id=@sid AND e.enrol_status='Pending Payment'",
                            con2))
                        {
                            c2.Parameters.AddWithValue("@sid", StudentId);
                            using (var dr = c2.ExecuteReader())
                                while (dr.Read()) tmpList.Add(dr[0].ToString());
                        }
                    }
                    courseIds = tmpList.ToArray();
                }
                catch { }
            }

            if (courseIds.Length == 0)
            {
                ShowError("No course data found. Please go back and try again.");
                // Re-show form so user can retry
                pnlPaymentForm.Visible = true;
                pnlSuccess.Visible = false;
                LoadCourseItems();
                SetupVA();
                return;
            }

            // Recalculate total if lost
            if (total <= 0)
            {
                try
                {
                    using (var con2 = new SqlConnection(ConnStr))
                    {
                        con2.Open();
                        foreach (string c2 in courseIds)
                        {
                            using (var cmd2 = new SqlCommand(
                                "SELECT ISNULL(credits,3) FROM course WHERE course_id=@cid", con2))
                            {
                                cmd2.Parameters.AddWithValue("@cid", c2.Trim());
                                var r = cmd2.ExecuteScalar();
                                if (r != null && r != DBNull.Value)
                                    total += Convert.ToInt32(r) * FeePerCredit;
                            }
                        }
                    }
                }
                catch { total = courseIds.Length * 3 * FeePerCredit; } // last resort estimate
            }

            var paymentIds = new List<int>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var tx = con.BeginTransaction())
                    {
                        try
                        {
                            foreach (string courseId in courseIds)
                            {
                                string cid = courseId.Trim();
                                if (string.IsNullOrEmpty(cid)) continue;

                                // Get credits
                                int credits = 3;
                                using (var c = new SqlCommand(
                                    "SELECT ISNULL(credits,3) FROM course WHERE course_id=@cid", con, tx))
                                {
                                    c.Parameters.AddWithValue("@cid", cid);
                                    var res = c.ExecuteScalar();
                                    if (res != null && res != DBNull.Value)
                                        credits = Convert.ToInt32(res);
                                }
                                int amt = credits * FeePerCredit;

                                // Skip if already paid
                                using (var c = new SqlCommand(
                                    "SELECT COUNT(*) FROM payment " +
                                    "WHERE student_id=@sid AND course_id=@cid AND status='Success'",
                                    con, tx))
                                {
                                    c.Parameters.AddWithValue("@sid", StudentId);
                                    c.Parameters.AddWithValue("@cid", cid);
                                    if ((int)c.ExecuteScalar() > 0) continue;
                                }

                                // INSERT payment
                                int pid = 0;
                                using (var cmd = new SqlCommand(
                                    "INSERT INTO payment(student_id,course_id,bank_name,amount,status,created_at) " +
                                    "OUTPUT INSERTED.payment_id " +
                                    "VALUES(@sid,@cid,@bank,@amt,'Success',GETDATE())", con, tx))
                                {
                                    cmd.Parameters.AddWithValue("@sid", StudentId);
                                    cmd.Parameters.AddWithValue("@cid", cid);
                                    cmd.Parameters.AddWithValue("@bank", bank);
                                    cmd.Parameters.AddWithValue("@amt", amt);
                                    pid = (int)cmd.ExecuteScalar();
                                }
                                paymentIds.Add(pid);

                                // FIX: UPDATE enrollment → 'Active'
                                // Covers both 'Pending Payment' and edge-case 'Pending'
                                using (var cmd = new SqlCommand(
                                    "UPDATE enrollment SET enrol_status='Active' " +
                                    "WHERE student_id=@sid " +
                                    "  AND CAST(course_id AS VARCHAR(20))=@cid " +
                                    "  AND enrol_status IN ('Pending Payment','Pending')",
                                    con, tx))
                                {
                                    cmd.Parameters.AddWithValue("@sid", StudentId);
                                    cmd.Parameters.AddWithValue("@cid", cid);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            tx.Commit();
                        }
                        catch (Exception ex2)
                        {
                            tx.Rollback();
                            ShowError("Payment transaction failed: " + ex2.Message);
                            pnlPaymentForm.Visible = true;
                            pnlSuccess.Visible = false;
                            LoadCourseItems();
                            SetupVA();
                            return;
                        }
                    }
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Error: " + ex.Message); return; }

            // ── Payment committed — show success ──
            pnlPaymentForm.Visible = false;
            pnlSuccess.Visible = true;

            // FIX: Tell JS the payment is done (hides processing overlay)
            hfPaymentDone.Value = "1";

            string firstPid = paymentIds.Count > 0 ? paymentIds[0].ToString() : "0";
            lblReceiptInvNo.Text = "INV-" + firstPid.PadLeft(4, '0');
            lblReceiptStudent.Text = (Session["StudentName"]?.ToString() ?? "") + " (ID: " + StudentId + ")";
            lblReceiptCourses.Text = string.Join(", ", courseIds);
            lblReceiptBank.Text = bank;
            lblReceiptDate.Text = DateTime.Now.ToString("dd MMM yyyy, HH:mm");
            lblReceiptTotal.Text = total.ToString("N2");

            if (paymentIds.Count > 0)
                lnkDownloadInvoice.NavigateUrl = "~/InvoicePayment.aspx?pid=" + paymentIds[0];
            else
                lnkDownloadInvoice.Visible = false;
        }

        private bool IsConnErr(SqlException ex) =>
            ex.Number == -2 || ex.Number == 2 || ex.Number == 53 ||
            ex.Message.IndexOf("timeout", StringComparison.OrdinalIgnoreCase) >= 0;

        private void RedirectTimeout()
        {
            Response.Redirect("~/Login.aspx?reason=timeout", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string msg) { lblError.Text = msg; lblError.Visible = true; }

        public class CourseItem
        {
            public string CourseId { get; set; }
            public string CourseName { get; set; }
            public int Credits { get; set; }
            public decimal Fee { get; set; }
            public string FeeFormatted { get; set; }
        }
    }
}