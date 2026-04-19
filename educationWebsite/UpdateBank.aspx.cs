// ================================================================
//  UpdateBank.aspx.cs
//
//  ALUR KERJA:
//  1. Page_Load → cek session, panggil LoadSavedBank()
//  2. LoadSavedBank() → baca dari Session (primary) atau
//     dari payment.bank_name terbaru (fallback dari DB)
//  3. Tampilkan bank tersimpan di "Current Bank" card
//  4. btnSave_Click → validasi → simpan ke Session + update
//     payment.bank_name di DB → refresh display
//
//  LOGIKA PENYIMPANAN:
//  ERD TIDAK punya tabel bank_details terpisah.
//  Solusi: simpan di Session["Bank*"] untuk sesi ini,
//          dan update payment.bank_name di semua record
//          payment student ini agar history sesuai.
//
//  CONTROL IDs (ASPX baru):
//    ddlBank         → asp:DropDownList
//    txtOtherBank    → asp:TextBox (Other bank name)
//    txtHolder       → asp:TextBox (account holder)
//    txtAccount      → asp:TextBox (account number)
//    btnSave         → asp:Button
//    pnlNoBank       → Panel shown when no bank saved
//    pnlBankInfo     → Panel shown when bank is saved
//    lblCurBank      → current bank name label
//    lblCurHolder    → current account holder label
//    lblCurAccount   → current account number (masked) label
// ================================================================
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class UpdateBank : Page
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

            if (!IsPostBack)
            {
                LoadSavedBank();
            }
        }

        // ── 2. Load saved bank (Session first, then DB fallback) ──────────
        private void LoadSavedBank()
        {
            string bank = Session["BankName"]?.ToString() ?? "";
            string holder = Session["BankAccountHolder"]?.ToString() ?? "";
            string account = Session["BankAccountNumber"]?.ToString() ?? "";

            // If not in session, try to get bank name from most recent payment
            if (string.IsNullOrEmpty(bank))
            {
                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand(
                        @"SELECT TOP 1 bank_name FROM payment
                          WHERE student_id = @sid AND bank_name IS NOT NULL
                          ORDER BY created_at DESC", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        con.Open();
                        var r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) bank = r.ToString();
                    }
                }
                catch { }
            }

            // Display current bank section
            bool hasBank = !string.IsNullOrEmpty(bank) || !string.IsNullOrEmpty(holder);
            pnlNoBank.Visible = !hasBank;
            pnlBankInfo.Visible = hasBank;

            if (hasBank)
            {
                lblCurBank.Text = string.IsNullOrEmpty(bank) ? "—" : bank;
                lblCurHolder.Text = string.IsNullOrEmpty(holder) ? "—" : holder;
                lblCurAccount.Text = string.IsNullOrEmpty(account) ? "—" : MaskAccount(account);
            }

            // Pre-fill form fields from session
            if (!string.IsNullOrEmpty(bank))
            {
                var item = ddlBank.Items.FindByValue(bank);
                if (item != null)
                    ddlBank.SelectedValue = bank;
                else
                {
                    ddlBank.SelectedValue = "Other";
                    txtOtherBank.Text = bank;
                }
            }

            txtHolder.Text = holder;
            txtAccount.Text = account;
        }

        // ── 3. Save bank details ──────────────────────────────────────────
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string bank = ddlBank.SelectedValue == "Other"
                          ? txtOtherBank.Text.Trim()
                          : ddlBank.SelectedValue;

            string holder = txtHolder.Text.Trim();
            string account = txtAccount.Text.Trim();

            if (string.IsNullOrEmpty(bank))
            {
                ShowError("Please select or enter a bank name.");
                return;
            }

            if (string.IsNullOrEmpty(holder))
            {
                ShowError("Account holder name is required.");
                return;
            }

            if (string.IsNullOrEmpty(account))
            {
                ShowError("Account number is required.");
                return;
            }

            try
            {
                // Save to session (persists for this browser session)
                Session["BankName"] = bank;
                Session["BankAccountHolder"] = holder;
                Session["BankAccountNumber"] = account;

                // Also update bank_name on existing payment records in DB
                // so PaymentHistory shows the correct bank name
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "UPDATE payment SET bank_name = @bank WHERE student_id = @sid", con))
                {
                    cmd.Parameters.AddWithValue("@bank", bank);
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    cmd.ExecuteNonQuery(); // ok if 0 rows (no payments yet)
                }

                // Show success + refresh display
                pnlSuccess.Visible = true;
                pnlError.Visible = false;

                pnlNoBank.Visible = false;
                pnlBankInfo.Visible = true;
                lblCurBank.Text = bank;
                lblCurHolder.Text = holder;
                lblCurAccount.Text = MaskAccount(account);
            }
            catch (Exception ex)
            {
                ShowError("An error occurred: " + ex.Message);
            }
        }

        // ── Helpers ───────────────────────────────────────────────────────

        // Mask middle digits: "1234567890" → "1234****90"
        private static string MaskAccount(string acct)
        {
            if (string.IsNullOrEmpty(acct) || acct.Length < 4) return acct;
            int show = Math.Min(4, acct.Length / 3);
            int stars = acct.Length - show * 2;
            if (stars < 0) stars = 0;
            return acct.Substring(0, show) +
                   new string('*', stars) +
                   acct.Substring(acct.Length - show);
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }
    }
}