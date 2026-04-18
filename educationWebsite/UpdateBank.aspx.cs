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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCurrentBankInfo();
            }
        }

        // ── Load saved bank details from session or last payment ─────────
        private void LoadCurrentBankInfo()
        {
            string savedBank = Session["BankName"]?.ToString() ?? "";
            string savedHolder = Session["BankAccountHolder"]?.ToString() ?? "";
            string savedAccount = Session["BankAccountNumber"]?.ToString() ?? "";

            // If not in session, try to load from last payment record
            if (string.IsNullOrEmpty(savedBank))
            {
                try
                {
                    using (var con = new SqlConnection(ConnStr))
                    using (var cmd = new SqlCommand(
                        "SELECT TOP 1 bank_name FROM payment WHERE student_id=@sid AND bank_name IS NOT NULL ORDER BY created_at DESC", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        con.Open();
                        var r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value)
                            savedBank = r.ToString();
                    }
                }
                catch { }
            }

            if (!string.IsNullOrEmpty(savedBank) || !string.IsNullOrEmpty(savedHolder))
            {
                pnlNoBankInfo.Visible = false;
                pnlBankInfo.Visible = true;

                lblCurrentBank.Text = string.IsNullOrEmpty(savedBank) ? "—" : savedBank;
                lblCurrentHolder.Text = string.IsNullOrEmpty(savedHolder) ? "—" : savedHolder;
                lblCurrentAccount.Text = string.IsNullOrEmpty(savedAccount) ? "—" : MaskAccount(savedAccount);

                // Pre-fill form
                var item = ddlBankName.Items.FindByValue(savedBank);
                if (item != null)
                    ddlBankName.SelectedValue = savedBank;
                else if (!string.IsNullOrEmpty(savedBank))
                {
                    ddlBankName.SelectedValue = "Other";
                    txtOtherBank.Text = savedBank;
                    otherBankGroup.Style["display"] = "block";
                }

                txtAccountHolder.Text = savedHolder;
                txtAccountNumber.Text = savedAccount;
            }
        }

        // ── Save bank details ────────────────────────────────────────────
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string bankName = ddlBankName.SelectedValue == "Other"
                              ? txtOtherBank.Text.Trim()
                              : ddlBankName.SelectedValue;

            string accountHolder = txtAccountHolder.Text.Trim();
            string accountNumber = txtAccountNumber.Text.Trim();

            if (string.IsNullOrEmpty(bankName))
            {
                ShowError("Please select or enter a bank name.");
                return;
            }

            try
            {
                // Save to session (primary storage — no dedicated table in ERD)
                Session["BankName"] = bankName;
                Session["BankAccountHolder"] = accountHolder;
                Session["BankAccountNumber"] = accountNumber;

                // Also update bank_name on existing payment records so history shows correct bank
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "UPDATE payment SET bank_name=@bank WHERE student_id=@sid", con))
                {
                    cmd.Parameters.AddWithValue("@bank", bankName);
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    cmd.ExecuteNonQuery(); // ok if 0 rows affected
                }

                pnlSuccess.Visible = true;
                pnlError.Visible = false;

                // Refresh display
                lblCurrentBank.Text = bankName;
                lblCurrentHolder.Text = accountHolder;
                lblCurrentAccount.Text = MaskAccount(accountNumber);
                pnlNoBankInfo.Visible = false;
                pnlBankInfo.Visible = true;
            }
            catch (Exception ex)
            {
                ShowError("An error occurred: " + ex.Message);
            }
        }

        // Mask middle digits of account number for display
        private static string MaskAccount(string acct)
        {
            if (string.IsNullOrEmpty(acct) || acct.Length < 4) return acct;
            int show = Math.Min(4, acct.Length / 3);
            return acct.Substring(0, show) + new string('*', acct.Length - show * 2) + acct.Substring(acct.Length - show);
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }
    }
}