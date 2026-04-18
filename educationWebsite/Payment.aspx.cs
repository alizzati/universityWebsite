// Payment.aspx.cs — FIXED namespace to UniversitySystem
using System;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class Payment : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            { Response.Redirect("~/Login.aspx"); return; }

            if (!IsPostBack)
            {
                lblStudentName.Text = Session["StudentName"]?.ToString() ?? "Student";
                lblStudentInfo.Text = "Student ID: " + Session["StudentId"]?.ToString();
            }
        }
    }
}