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

        // CourseIds dari QueryString — sekarang INT
        private int[] CourseIds
        {
            get
            {
                string raw = Request.QueryString["courses"];
                if (string.IsNullOrEmpty(raw)) return new int[0];
                var result = new List<int>();
                foreach (string s in raw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                {
                    int n;
                    if (int.TryParse(s.Trim(), out n)) result.Add(n);
                }
                return result.ToArray();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            { Response.Redirect("~/Login.aspx?reason=session"); return; }

            int[] qs = CourseIds;
            if (qs.Length > 0)
                ViewState["PaymentCourses"] = string.Join(",", qs);

            if (!IsPostBack)
            {
                hfPaymentDone.Value = "0";
                txtStudentId.Text = StudentId.ToString();
                pnlPaymentForm.Visible = true;
                pnlSuccess.Visible = false;

                LoadCourseItems();
                SetupVA("Maybank2u");
            }
        }

        private int[] GetCourseIdsFromViewState()
        {
            string s = ViewState["PaymentCourses"]?.ToString() ?? "";
            if (string.IsNullOrEmpty(s)) return new int[0];
            var result = new List<int>();
            foreach (string part in s.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                int n;
                if (int.TryParse(part.Trim(), out n)) result.Add(n);
            }
            return result.ToArray();
        }

        private void LoadCourseItems()
        {
            int[] ids = GetCourseIdsFromViewState();
            if (ids.Length == 0) { LoadAllPendingCourses(); return; }

            var list = new List<CourseItem>();
            decimal total = 0;

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    foreach (int cid in ids)
                    {
                        using (var cmd = new SqlCommand(
                            "SELECT course_id, " +
                            "       ISNULL(course_code, CAST(course_id AS VARCHAR(20))) AS course_code, " +
                            "       course_name, " +
                            "       ISNULL(credits, 3) AS credits, " +
                            "       ISNULL(fee, ISNULL(credits,3) * " + FeePerCredit + ") AS fee " +
                            "FROM course WHERE course_id = @cid", con))
                        {
                            cmd.Parameters.AddWithValue("@cid", cid);
                            using (var dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    int credits = Convert.ToInt32(dr["credits"]);
                                    decimal fee;
                                    try { fee = Convert.ToDecimal(dr["fee"]); }
                                    catch { fee = credits * FeePerCredit; }

                                    total += fee;
                                    list.Add(new CourseItem
                                    {
                                        CourseId = Convert.ToInt32(dr["course_id"]),
                                        CourseCode = dr["course_code"].ToString(),
                                        CourseName = dr["course_name"].ToString(),
                                        Credits = credits,
                                        Fee = fee,
                                        FeeFormatted = fee.ToString("N2")
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
                "SELECT c.course_id, " +
                "       ISNULL(c.course_code, CAST(c.course_id AS VARCHAR(20))) AS course_code, " +
                "       c.course_name, " +
                "       ISNULL(c.credits, 3) AS credits, " +
                "       ISNULL(c.fee, ISNULL(c.credits,3) * 150) AS fee " +
                "FROM enrollment e " +
                "JOIN course c ON c.course_id = e.course_id " +
                "WHERE e.student_id = @sid AND e.enrol_status = 'Pending Payment' " +
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
                            decimal fee;
                            try { fee = Convert.ToDecimal(dr["fee"]); }
                            catch { fee = credits * FeePerCredit; }

                            total += fee;
                            list.Add(new CourseItem
                            {
                                CourseId = Convert.ToInt32(dr["course_id"]),
                                CourseCode = dr["course_code"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Credits = credits,
                                Fee = fee,
                                FeeFormatted = fee.ToString("N2")
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

            var cids = new List<int>();
            foreach (var ci in list) cids.Add(ci.CourseId);
            ViewState["PaymentCourses"] = string.Join(",", cids);
        }

        private void SetupVA(string bankName)
        {
            pnlVA.Visible = true;
            lblVABank.Text = bankName;
            lblVANumber.Text = GenerateVA(StudentId, bankName);
            lblVAAmount.Text = hfGrandTotal.Value;
        }

        private static string GenerateVA(int studentId, string bankName)
        {
            string prefix;
            switch (bankName)
            {
                case "CIMB Clicks": prefix = "2234"; break;
                case "Public Bank": prefix = "3344"; break;
                case "RHB Online": prefix = "4455"; break;
                default: prefix = "1234"; break;
            }
            return prefix + studentId.ToString().PadLeft(6, '0') + DateTime.Today.DayOfYear.ToString().PadLeft(3, '0');
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string bank = rbMaybank.Checked ? "Maybank2u"
                        : rbCimb.Checked ? "CIMB Clicks"
                        : rbPublic.Checked ? "Public Bank"
                        : rbRhb.Checked ? "RHB Online"
                        : "Maybank2u";

            decimal total = ViewState["PaymentTotal"] != null ? (decimal)ViewState["PaymentTotal"] : 0;
            int[] courseIds = GetCourseIdsFromViewState();

            // Fallback: reload dari enrollment jika ViewState kosong
            if (courseIds.Length == 0)
            {
                try
                {
                    var tmp = new List<int>();
                    using (var con2 = new SqlConnection(ConnStr))
                    {
                        con2.Open();
                        using (var c2 = new SqlCommand(
                            "SELECT course_id FROM enrollment " +
                            "WHERE student_id = @sid AND enrol_status = 'Pending Payment'", con2))
                        {
                            c2.Parameters.AddWithValue("@sid", StudentId);
                            using (var dr = c2.ExecuteReader())
                                while (dr.Read()) tmp.Add(Convert.ToInt32(dr[0]));
                        }
                    }
                    courseIds = tmp.ToArray();
                }
                catch { }
            }

            if (courseIds.Length == 0)
            {
                ShowError("No course data found. Please go back and try again.");
                pnlPaymentForm.Visible = true;
                pnlSuccess.Visible = false;
                LoadCourseItems();
                SetupVA(bank);
                return;
            }

            // Hitung total jika ViewState hilang
            if (total <= 0)
            {
                try
                {
                    using (var con2 = new SqlConnection(ConnStr))
                    {
                        con2.Open();
                        foreach (int cid2 in courseIds)
                        {
                            using (var cmd2 = new SqlCommand(
                                "SELECT ISNULL(fee, ISNULL(credits,3) * " + FeePerCredit + ") " +
                                "FROM course WHERE course_id = @cid", con2))
                            {
                                cmd2.Parameters.AddWithValue("@cid", cid2);
                                var r = cmd2.ExecuteScalar();
                                if (r != null && r != DBNull.Value)
                                    total += Convert.ToDecimal(r);
                            }
                        }
                    }
                }
                catch { total = courseIds.Length * 3 * FeePerCredit; }
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
                            foreach (int courseId in courseIds)
                            {
                                // Hitung fee
                                decimal amt = 0;
                                using (var c = new SqlCommand(
                                    "SELECT ISNULL(fee, ISNULL(credits,3) * " + FeePerCredit + ") " +
                                    "FROM course WHERE course_id = @cid", con, tx))
                                {
                                    c.Parameters.AddWithValue("@cid", courseId);
                                    var res = c.ExecuteScalar();
                                    amt = (res != null && res != DBNull.Value)
                                          ? Convert.ToDecimal(res) : 3 * FeePerCredit;
                                }

                                // Cek duplikat payment
                                // payment.course_id = INT (FK ke course.course_id INT)
                                using (var c = new SqlCommand(
                                    "SELECT COUNT(*) FROM payment " +
                                    "WHERE student_id = @sid AND course_id = @cid AND status = 'Success'",
                                    con, tx))
                                {
                                    c.Parameters.AddWithValue("@sid", StudentId);
                                    c.Parameters.AddWithValue("@cid", courseId);
                                    if ((int)c.ExecuteScalar() > 0) continue;
                                }

                                // INSERT payment
                                // payment_id = IDENTITY → tidak perlu diisi
                                // course_id  = INT FK
                                int pid = 0;
                                using (var cmd = new SqlCommand(
                                    "INSERT INTO payment(student_id, course_id, bank_name, amount, status, created_at) " +
                                    "OUTPUT INSERTED.payment_id " +
                                    "VALUES(@sid, @cid, @bank, @amt, 'Success', GETDATE())", con, tx))
                                {
                                    cmd.Parameters.AddWithValue("@sid", StudentId);
                                    cmd.Parameters.AddWithValue("@cid", courseId);
                                    cmd.Parameters.AddWithValue("@bank", bank);
                                    cmd.Parameters.AddWithValue("@amt", amt);
                                    pid = (int)cmd.ExecuteScalar();
                                }
                                paymentIds.Add(pid);

                                // UPDATE enrollment → Active
                                // enrollment.course_id = INT → compare langsung
                                using (var cmd = new SqlCommand(
                                    "UPDATE enrollment " +
                                    "SET    enrol_status = 'Active' " +
                                    "WHERE  student_id   = @sid " +
                                    "  AND  course_id    = @cid " +
                                    "  AND  enrol_status IN ('Pending Payment','Pending')", con, tx))
                                {
                                    cmd.Parameters.AddWithValue("@sid", StudentId);
                                    cmd.Parameters.AddWithValue("@cid", courseId);
                                    cmd.ExecuteNonQuery();
                                }

                                // INSERT add_drop_history
                                // course_id = INT FK ke course.course_id
                                using (var cmd = new SqlCommand(
                                    "IF NOT EXISTS (" +
                                    "  SELECT 1 FROM add_drop_history " +
                                    "  WHERE student_id=@sid AND course_id=@cid AND action_type='Add'" +
                                    ") " +
                                    "INSERT INTO add_drop_history(student_id, course_id, action_type, action_date) " +
                                    "VALUES(@sid, @cid, 'Add', CAST(GETDATE() AS DATE))", con, tx))
                                {
                                    cmd.Parameters.AddWithValue("@sid", StudentId);
                                    cmd.Parameters.AddWithValue("@cid", courseId);
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
                            SetupVA(bank);
                            return;
                        }
                    }
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Error: " + ex.Message); return; }

            pnlPaymentForm.Visible = false;
            pnlSuccess.Visible = true;
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
            public int CourseId { get; set; }
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public int Credits { get; set; }
            public decimal Fee { get; set; }
            public string FeeFormatted { get; set; }
        }
    }
}