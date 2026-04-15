using System;
using System.Web.UI;

namespace UniversitySystem.Controls
{
    public partial class NavBar : UserControl
    {
        // ── Nama student untuk ditunjuk di navbar ─────────────────────────
        public string StudentName
        {
            get
            {
                if (Session["StudentName"] != null)
                    return Session["StudentName"].ToString();
                return "Student"; // fallback
            }
        }

        // ── Highlight link aktif berdasarkan nama page sekarang ───────────
        // Penggunaan: class='<%=ActiveClass("TeachingEvaluation") %>'
        public string ActiveClass(string pageName)
        {
            string currentPage = System.IO.Path.GetFileNameWithoutExtension(
                Request.AppRelativeCurrentExecutionFilePath ?? "");

            return currentPage.Equals(pageName, StringComparison.OrdinalIgnoreCase)
                ? "active"
                : "";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect ke Login jika belum login
            // Uncomment baris ini selepas halaman Login siap:
            // if (Session["StudentId"] == null)
            //     Response.Redirect("~/Login.aspx");
        }
    }
}
