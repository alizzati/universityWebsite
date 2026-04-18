using System;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Cache.SetExpires(DateTime.UtcNow.AddDays(-1));
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            Response.Redirect("~/login.aspx?reason=session", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}