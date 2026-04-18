using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

// ═══════════════════════════════════════════════════════════════════════════
//  FIXES:
//    1. Namespace changed: educationWebsite → UniversitySystem
//    2. The uploaded AddDrop.aspx.cs actually CONTAINED the AddDropHistory logic
//       (it was placed in the wrong file). Moved here where it belongs.
//    3. AddDrop.aspx.cs now has the proper Add/Drop logic (see that file).
//    4. ERD: add_drop_history(history_id, student_id int FK, course_id int FK,
//                             action_type varchar, action_date DATE)
//    5. Session key: "StudentId" (int, UniversitySystem convention)
// ═══════════════════════════════════════════════════════════════════════════
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
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStatistics();
                LoadHistory();
            }
        }

        // ── Statistics ────────────────────────────────────────────────────
        private void LoadStatistics()
        {
            const string sql = @"
                SELECT
                    SUM(CASE WHEN action_type = 'Add'  THEN 1 ELSE 0 END) AS total_adds,
                    SUM(CASE WHEN action_type = 'Drop' THEN 1 ELSE 0 END) AS total_drops,
                    COUNT(*)                                               AS total_actions
                FROM add_drop_history
                WHERE student_id = @sid";

            const string enrollSql = @"
                SELECT COUNT(*) FROM enrollment
                WHERE student_id = @sid AND enrol_status = 'Active'";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        using (var dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                lblTotalAdds.Text = dr["total_adds"] == DBNull.Value ? "0" : dr["total_adds"].ToString();
                                lblTotalDrops.Text = dr["total_drops"] == DBNull.Value ? "0" : dr["total_drops"].ToString();
                                lblTotalActions.Text = dr["total_actions"] == DBNull.Value ? "0" : dr["total_actions"].ToString();
                            }
                        }
                    }
                    using (var cmd2 = new SqlCommand(enrollSql, con))
                    {
                        cmd2.Parameters.AddWithValue("@sid", StudentId);
                        lblCurrentEnrollments.Text = cmd2.ExecuteScalar().ToString();
                    }
                }
            }
            catch { /* stats non-critical; show zeros */ }
        }

        // ── Load history with filters ─────────────────────────────────────
        private void LoadHistory()
        {
            var sb = new StringBuilder(@"
                SELECT
                    h.history_id  AS HistoryId,
                    h.action_date AS ActionDate,
                    h.action_type AS Action,
                    ISNULL(c.course_id,   CAST(h.course_id AS VARCHAR)) AS CourseCode,
                    ISNULL(c.course_name, 'Unknown')                    AS CourseName,
                    ISNULL(c.credits, 0)                                AS CreditHours
                FROM   add_drop_history h
                LEFT   JOIN course c ON c.course_id = CAST(h.course_id AS VARCHAR(20))
                WHERE  h.student_id = @sid");

            if (!string.IsNullOrEmpty(ddlActionType.SelectedValue))
                sb.Append(" AND h.action_type = @action");

            if (!string.IsNullOrEmpty(ddlDateRange.SelectedValue))
                sb.Append(" AND h.action_date >= @cutoff");

            sb.Append(" ORDER BY h.action_date DESC");

            var dt = new DataTable();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sb.ToString(), con))
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
                    using (var da = new SqlDataAdapter(cmd))
                        da.Fill(dt);
                }
            }
            catch (SqlException ex) when (ex.Number == -2 || ex.Number == 2 || ex.Number == 53)
            {
                Response.Redirect("~/Login.aspx?reason=timeout");
                return;
            }
            catch { /* show empty grid */ }

            gvHistory.DataSource = dt;
            gvHistory.DataBind();
        }

        // ── Filter dropdowns changed ──────────────────────────────────────
        protected void ddlFilter_Changed(object sender, EventArgs e)
        {
            LoadHistory();
        }

        // ── GridView paging ───────────────────────────────────────────────
        protected void gvHistory_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvHistory.PageIndex = e.NewPageIndex;
            LoadHistory();
        }

        // ── Export as TXT ─────────────────────────────────────────────────
        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            var sb = new StringBuilder();
            sb.AppendLine("ADD/DROP HISTORY REPORT");
            sb.AppendLine("==============================");
            sb.AppendLine("Student ID : " + StudentId);
            sb.AppendLine("Generated  : " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
            sb.AppendLine();

            const string sql = @"
                SELECT h.action_date, h.action_type,
                       ISNULL(c.course_id, CAST(h.course_id AS VARCHAR)) AS CourseCode,
                       ISNULL(c.course_name, 'Unknown') AS CourseName
                FROM   add_drop_history h
                LEFT   JOIN course c ON c.course_id = CAST(h.course_id AS VARCHAR(20))
                WHERE  h.student_id = @sid
                ORDER  BY h.action_date DESC";

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
                                dr["CourseCode"] + " - " + dr["CourseName"]);
                }
            }
            catch { }

            Response.Clear();
            Response.ContentType = "text/plain";
            Response.AddHeader("Content-Disposition", "attachment; filename=AddDropHistory.txt");
            Response.Write(sb.ToString());
            Response.End();
        }

        // ── Export as CSV ─────────────────────────────────────────────────
        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            var sb = new StringBuilder();
            sb.AppendLine("Date,Action,Course Code,Course Name,Credits");

            const string sql = @"
                SELECT h.action_date, h.action_type,
                       ISNULL(c.course_id, CAST(h.course_id AS VARCHAR)) AS CourseCode,
                       ISNULL(c.course_name, 'Unknown') AS CourseName,
                       ISNULL(c.credits, 0) AS Credits
                FROM   add_drop_history h
                LEFT   JOIN course c ON c.course_id = CAST(h.course_id AS VARCHAR(20))
                WHERE  h.student_id = @sid
                ORDER  BY h.action_date DESC";

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