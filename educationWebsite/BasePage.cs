using System;
using System.Web.UI;

namespace payment
{
    /// <summary>
    /// Inherit this instead of Page on any page that requires login.
    /// Example: public partial class onlinepaymet : BasePage
    /// </summary>
    public class BasePage : Page
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (Session["StudentID"] == null)
            {
                Response.Redirect(
                    "~/login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl),
                    false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }
    }
}
