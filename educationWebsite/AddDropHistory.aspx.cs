using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace UniversitySystem
{
    public partial class AddDropHistory : Page
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
                LoadStatistics();
                LoadHistory();
            }
        }

        private void LoadStatistics()
        {
            const string sqlHist =
                "SELECT " +
                "  SUM(CASE WHEN action_type='Add'  THEN 1 ELSE 0 END) AS adds, " +
                "  SUM(CASE WHEN action_type='Drop' THEN 1 ELSE 0 END) AS drops, " +
                "  COUNT(*) AS total " +
                "FROM add_drop_history WHERE student_id = @sid";

            const string sqlEnrol =
                "SELECT COUNT(*) FROM enrollment " +
                "WHERE student_id = @sid AND enrol_status = 'Active'";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = new SqlCommand(sqlHist, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        using (var dr = cmd.ExecuteReader())
                            if (dr.Read())
                            {
                                lblTotalAdds.Text = dr["adds"] == DBNull.Value ? "0" : dr["adds"].ToString();
                                lblTotalDrops.Text = dr["drops"] == DBNull.Value ? "0" : dr["drops"].ToString();
                                lblTotalActions.Text = dr["total"] == DBNull.Value ? "0" : dr["total"].ToString();
                            }
                    }
                    using (var cmd = new SqlCommand(sqlEnrol, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        lblCurrentEnrollments.Text = cmd.ExecuteScalar()?.ToString() ?? "0";
                    }
                }
            }
            catch { }
        }

        private void LoadHistory()
        {
            string actionFilter = "";
            string dateFilter = "";

            if (!string.IsNullOrEmpty(ddlActionType.SelectedValue))
                actionFilter = " AND h.action_type = @action";
            if (!string.IsNullOrEmpty(ddlDateRange.SelectedValue))
                dateFilter = " AND h.action_date >= @cutoff";

            // add_drop_history.course_id = INT FK → course.course_id INT
            // JOIN langsung, tidak perlu CAST
            string sql =
                "SELECT " +
                "    h.action_date AS ActionDate, " +
                "    h.action_type AS Action, " +
                "    ISNULL(c.course_code, CAST(c.course_id AS VARCHAR(20))) AS CourseCode, " +
                "    ISNULL(c.course_name, 'Unknown') AS CourseName, " +
                "    ISNULL(c.credits, 0) AS CreditHours " +
                "FROM add_drop_history h " +
                "LEFT JOIN course c ON c.course_id = h.course_id " +
                "WHERE h.student_id = @sid" + actionFilter + dateFilter +
                " ORDER BY h.action_date DESC";

            var dt = new DataTable();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 15;
                    cmd.Parameters.AddWithValue("@sid", StudentId);

                    if (!string.IsNullOrEmpty(ddlActionType.SelectedValue))
                        cmd.Parameters.AddWithValue("@action", ddlActionType.SelectedValue);

                    if (!string.IsNullOrEmpty(ddlDateRange.SelectedValue))
                    {
                        int days = Convert.ToInt32(ddlDateRange.SelectedValue);
                        cmd.Parameters.AddWithValue("@cutoff", DateTime.Now.AddDays(-days));
                    }

                    con.Open();
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (SqlException ex) when (ex.Number == -2 || ex.Number == 2 || ex.Number == 53)
            { Response.Redirect("~/Login.aspx?reason=timeout"); return; }
            catch { }

            gvHistory.DataSource = dt;
            gvHistory.DataBind();
        }

        protected void ddlFilter_Changed(object sender, EventArgs e) => LoadHistory();

        protected void gvHistory_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvHistory.PageIndex = e.NewPageIndex;
            LoadHistory();
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            var sb = new StringBuilder();
            sb.AppendLine("ADD/DROP HISTORY REPORT");
            sb.AppendLine("======================");
            sb.AppendLine("Student ID : " + StudentId);
            sb.AppendLine("Generated  : " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
            sb.AppendLine();

            const string sql =
                "SELECT h.action_date, h.action_type, " +
                "       ISNULL(c.course_code, CAST(c.course_id AS VARCHAR(20))) AS CourseCode, " +
                "       ISNULL(c.course_name, 'Unknown') AS CourseName " +
                "FROM add_drop_history h " +
                "LEFT JOIN course c ON c.course_id = h.course_id " +
                "WHERE h.student_id = @sid ORDER BY h.action_date DESC";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            sb.AppendLine(
                                Convert.ToDateTime(dr["action_date"]).ToString("yyyy-MM-dd") + " | " +
                                dr["action_type"].ToString().PadRight(4) + " | " +
                                dr["CourseCode"] + " — " + dr["CourseName"]);
                }
            }
            catch { }

            Response.Clear();
            Response.ContentType = "text/plain";
            Response.AddHeader("Content-Disposition", "attachment; filename=AddDropHistory.txt");
            Response.Write(sb.ToString());
            Response.End();
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            var sb = new StringBuilder();
            sb.AppendLine("Date,Action,Course Code,Course Name,Credits");

            const string sql =
                "SELECT h.action_date, h.action_type, " +
                "       ISNULL(c.course_code, CAST(c.course_id AS VARCHAR(20))) AS CourseCode, " +
                "       ISNULL(c.course_name, 'Unknown') AS CourseName, " +
                "       ISNULL(c.credits, 0) AS Credits " +
                "FROM add_drop_history h " +
                "LEFT JOIN course c ON c.course_id = h.course_id " +
                "WHERE h.student_id = @sid ORDER BY h.action_date DESC";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            sb.AppendLine(
                                Convert.ToDateTime(dr["action_date"]).ToString("yyyy-MM-dd") + "," +
                                dr["action_type"] + "," +
                                dr["CourseCode"] + ",\"" + dr["CourseName"] + "\"," +
                                dr["Credits"]);
                }
            }
            catch { }

            Response.Clear();
            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("Content-Disposition", "attachment; filename=AddDropHistory.csv");
            Response.Write(sb.ToString());
            Response.End();
        }
    }
}