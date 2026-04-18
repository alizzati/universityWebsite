// ================================================================
//  OnlinePayment.aspx.cs — COMPLETE
//
//  FLOW:
//    1. Page_Load: read ?courses=courseId1,courseId2 from query string
//       Load 'Pending Payment' courses → show fee table + VA
//    2. btnSubmit_Click: INSERT payment records + UPDATE enrollment → 'Active'
//       Show processing panel briefly → show success panel
//    3. Success: show receipt, link to invoice download
//
//  Virtual Account: generated deterministically per student + amount
//  Invoice download: InvoicePayment.aspx?pid=X&download=1
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
        private const int FeePerCredit = 150; // RM per credit

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        private int StudentId =>
            Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;

        // List of courseIds from query string (comma-separated)
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

            if (!IsPostBack)
            {
                txtStudentId.Text = StudentId.ToString();
                pnlPaymentForm.Visible = true;
                pnlProcessing.Visible = false;
                pnlSuccess.Visible = false;

                LoadCourseItems();
                SetupVA();
            }
        }

        // ── Load course items for the selected courses ────────────────────
        private void LoadCourseItems()
        {
            string[] ids = CourseIds;
            if (ids.Length == 0)
            {
                // No courses passed — load all 'Pending Payment' for this student
                LoadAllPendingCourses();
                return;
            }

            var list = new List<CourseItem>();
            decimal total = 0;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    foreach (string courseId in ids)
                    {
                        using (var cmd = new SqlCommand(
                            "SELECT c.course_id, c.course_name, ISNULL(c.credits,3) AS credits " +
                            "FROM course c WHERE c.course_id = @cid", con))
                        {
                            cmd.Parameters.AddWithValue("@cid", courseId.Trim());
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
            {
                ShowError("No valid courses found. Please go back and select courses again.");
                return;
            }

            rptCourseItems.DataSource = list;
            rptCourseItems.DataBind();
            lblGrandTotal.Text = total.ToString("N2");
            hfGrandTotal.Value = total.ToString("N2");

            // Store in ViewState so btnSubmit_Click can access
            ViewState["PaymentTotal"] = total;
            ViewState["PaymentCourses"] = string.Join(",", CourseIds);
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
                ShowError("No pending courses to pay for. <a href='OnlineEnrollment.aspx'>Enrol in a course first.</a>");
                btnSubmit.Enabled = false;
                return;
            }

            rptCourseItems.DataSource = list;
            rptCourseItems.DataBind();
            lblGrandTotal.Text = total.ToString("N2");
            hfGrandTotal.Value = total.ToString("N2");

            ViewState["PaymentTotal"] = total;
            var cids = new System.Collections.Generic.List<string>();
            foreach (var ci in list) cids.Add(ci.CourseId);
            ViewState["PaymentCourses"] = string.Join(",", cids);
        }

        // ── Generate Virtual Account ──────────────────────────────────────
        private void SetupVA()
        {
            pnlVA.Visible = true;
            string va = GenerateVA(StudentId);
            lblVABank.Text = "Maybank2u";
            lblVANumber.Text = va;
            lblVAAmount.Text = hfGrandTotal.Value;
            ViewState["VA"] = va;
        }

        // VA = deterministic: 1234 + student_id (zero-padded 6) + last 3 of day
        private static string GenerateVA(int studentId)
        {
            string sid = studentId.ToString().PadLeft(6, '0');
            string day = DateTime.Today.DayOfYear.ToString().PadLeft(3, '0');
            return "1234" + sid + day;
        }

        private static string GetVAForBank(string bank, int studentId)
        {
            string prefix;
            switch (bank)
            {
                case "CIMB Clicks": prefix = "7012"; break;
                case "Public Bank": prefix = "8888"; break;
                case "RHB Online": prefix = "2222"; break;
                default: prefix = "1234"; break; // Maybank
            }
            string sid = studentId.ToString().PadLeft(6, '0');
            string day = DateTime.Today.DayOfYear.ToString().PadLeft(3, '0');
            return prefix + sid + day;
        }

        // ── SUBMIT: process payment ───────────────────────────────────────
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string bank = rbMaybank.Checked ? "Maybank2u"
                        : rbCimb.Checked ? "CIMB Clicks"
                        : rbPublic.Checked ? "Public Bank"
                        : rbRhb.Checked ? "RHB Online"
                        : "Maybank2u";

            decimal total = ViewState["PaymentTotal"] != null
                                ? (decimal)ViewState["PaymentTotal"] : 0;
            string coursesStr = ViewState["PaymentCourses"]?.ToString() ?? string.Join(",", CourseIds);
            string[] courseIds = coursesStr.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            if (courseIds.Length == 0 || total <= 0)
            {
                ShowError("No payment data found. Please go back and try again.");
                return;
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

                                // Get fee for this course
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
                                    "SELECT COUNT(*) FROM payment WHERE student_id=@sid AND course_id=@cid AND status='Success'",
                                    con, tx))
                                {
                                    c.Parameters.AddWithValue("@sid", StudentId);
                                    c.Parameters.AddWithValue("@cid", cid);
                                    if ((int)c.ExecuteScalar() > 0) continue;
                                }

                                // INSERT payment — OUTPUT gives us the new payment_id
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

                                // UPDATE enrollment → 'Active'
                                using (var cmd = new SqlCommand(
                                    "UPDATE enrollment SET enrol_status='Active' " +
                                    "WHERE student_id=@sid AND CAST(course_id AS VARCHAR(20))=@cid " +
                                    "  AND enrol_status='Pending Payment'", con, tx))
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
                            ShowError("Payment failed: " + ex2.Message);
                            return;
                        }
                    }
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Error: " + ex.Message); return; }

            // ── Show success panel ──
            pnlPaymentForm.Visible = false;
            pnlProcessing.Visible = false;
            pnlSuccess.Visible = true;

            string firstPid = paymentIds.Count > 0 ? paymentIds[0].ToString() : "—";
            lblReceiptInvNo.Text = "INV-" + firstPid.PadLeft(4, '0');
            lblReceiptStudent.Text = Session["StudentName"]?.ToString() + " (ID: " + StudentId + ")";
            lblReceiptCourses.Text = string.Join(", ", courseIds);
            lblReceiptBank.Text = bank;
            lblReceiptDate.Text = DateTime.Now.ToString("dd MMM yyyy, HH:mm");
            lblReceiptTotal.Text = total.ToString("N2");

            // Invoice download link — uses first payment_id
            if (paymentIds.Count > 0)
                lnkDownloadInvoice.NavigateUrl = "~/InvoicePayment.aspx?pid=" + paymentIds[0] + "&download=1";
            else
                lnkDownloadInvoice.Visible = false;

            // Update steps bar to Done
            UpdateStepsDone();
        }

        private void UpdateStepsDone()
        {
            // Nothing needed — JS handles via pnlSuccess visibility
        }

        private bool IsConnErr(SqlException ex) =>
            ex.Number == -2 || ex.Number == 2 || ex.Number == 53 ||
            ex.Message.IndexOf("timeout", StringComparison.OrdinalIgnoreCase) >= 0;

        private void RedirectTimeout()
        {
            Response.Redirect("~/Login.aspx?reason=timeout", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            lblError.Visible = true;
        }

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