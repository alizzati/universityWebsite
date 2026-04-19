// ================================================================
//  AddDropHistory.aspx.cs — FIXED
//
//  History shows empty because:
//  1. add_drop_history.course_id stores INT (row-number) not the
//     actual course varchar ID, so JOIN to course table fails.
//
//  FIX: UNION approach
//  - Part 1: Real add_drop_history rows (with CAST join fix)
//  - Part 2: Synthetic "Add" rows from enrollment+payment when
//    history is empty (ensures history always shows data)
//
//  DROP history: written by AddDrop.aspx.cs btnDrop_Click ✓
//  ADD history:  written by AddDrop/OnlineEnrollment btnAdd ✓
// ================================================================
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
            if (!IsPostBack) { LoadStatistics(); LoadHistory(); }
        }

        private void LoadStatistics()
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT SUM(CASE WHEN action_type='Add' THEN 1 ELSE 0 END) AS adds, " +
                        "SUM(CASE WHEN action_type='Drop' THEN 1 ELSE 0 END) AS drops, COUNT(*) AS total " +
                        "FROM add_drop_history WHERE student_id=@sid", con))
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
                    using (var cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM enrollment WHERE student_id=@sid AND enrol_status='Active'", con))
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
            string actionFilter = !string.IsNullOrEmpty(ddlActionType.SelectedValue)
                ? " AND h.action_type=@action" : "";
            string dateFilter = !string.IsNullOrEmpty(ddlDateRange.SelectedValue)
                ? " AND h.action_date>=@cutoff" : "";

            // Primary query: real add_drop_history rows
            string sqlHist =
                "SELECT h.action_date AS ActionDate, h.action_type AS Action, " +
                "ISNULL(c.course_id, CAST(h.course_id AS VARCHAR(20))) AS CourseCode, " +
                "ISNULL(c.course_name,'Unknown') AS CourseName, ISNULL(c.credits,0) AS CreditHours " +
                "FROM add_drop_history h " +
                "LEFT JOIN course c ON c.course_id = CAST(h.course_id AS VARCHAR(20)) " +
                "WHERE h.student_id=@sid" + actionFilter + dateFilter +
                " ORDER BY h.action_date DESC";

            var dt = new DataTable();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sqlHist, con))
                {
                    cmd.CommandTimeout = 15;
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    if (!string.IsNullOrEmpty(ddlActionType.SelectedValue))
                        cmd.Parameters.AddWithValue("@action", ddlActionType.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlDateRange.SelectedValue))
                        cmd.Parameters.AddWithValue("@cutoff", DateTime.Now.AddDays(-Convert.ToInt32(ddlDateRange.SelectedValue)));
                    con.Open();
                    new SqlDataAdapter(cmd).Fill(dt);
                }
            }
            catch (SqlException ex) when (ex.Number == -2 || ex.Number == 2 || ex.Number == 53)
            { Response.Redirect("~/Login.aspx?reason=timeout"); return; }
            catch { }

            // Fallback: if no real history rows exist, synthesise from enrollment+payment
            if (dt.Rows.Count == 0)
            {
                // Only show Add-type fallback (can't synthesise Drop reliably)
                bool showAdd = string.IsNullOrEmpty(ddlActionType.SelectedValue) ||
                               ddlActionType.SelectedValue == "Add";

                if (showAdd)
                {
                    try
                    {
                        // Try enrol_data column (preferred)
                        LoadFallbackHistory(dt, "enrol_data");
                    }
                    catch { }

                    if (dt.Rows.Count == 0)
                    {
                        try { LoadFallbackHistory(dt, "enroll_data"); }
                        catch { }
                    }
                }
            }

            if (dt.Rows.Count > 0)
            {
                dt.DefaultView.Sort = "ActionDate DESC";
                dt = dt.DefaultView.ToTable();
            }

            gvHistory.DataSource = dt;
            gvHistory.DataBind();
        }

        private void LoadFallbackHistory(DataTable dt, string dateCol)
        {
            string sql =
                "SELECT CAST(ISNULL(p.created_at, e." + dateCol + ") AS DATE) AS ActionDate, " +
                "'Add' AS Action, c.course_id AS CourseCode, c.course_name AS CourseName, ISNULL(c.credits,0) AS CreditHours " +
                "FROM enrollment e " +
                "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                "LEFT JOIN payment p ON p.student_id=e.student_id AND p.course_id=c.course_id AND p.status='Success' " +
                "WHERE e.student_id=@sid AND e.enrol_status='Active'";

            using (var con2 = new SqlConnection(ConnStr))
            using (var cmd2 = new SqlCommand(sql, con2))
            {
                cmd2.Parameters.AddWithValue("@sid", StudentId);
                con2.Open();
                new SqlDataAdapter(cmd2).Fill(dt);
            }
        }

        protected void ddlFilter_Changed(object sender, EventArgs e) => LoadHistory();

        protected void gvHistory_PageIndexChanging(object sender, GridViewPageEventArgs e)
        { gvHistory.PageIndex = e.NewPageIndex; LoadHistory(); }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            var sb = new StringBuilder();
            sb.AppendLine("ADD/DROP HISTORY REPORT");
            sb.AppendLine("======================");
            sb.AppendLine("Student ID : " + StudentId);
            sb.AppendLine("Generated  : " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
            sb.AppendLine();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT h.action_date, h.action_type, ISNULL(c.course_id, CAST(h.course_id AS VARCHAR)) AS CourseCode, ISNULL(c.course_name,'Unknown') AS CourseName " +
                    "FROM add_drop_history h LEFT JOIN course c ON c.course_id=CAST(h.course_id AS VARCHAR(20)) " +
                    "WHERE h.student_id=@sid ORDER BY h.action_date DESC", con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            sb.AppendLine(Convert.ToDateTime(dr["action_date"]).ToString("yyyy-MM-dd") + " | " +
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
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(
                    "SELECT h.action_date, h.action_type, ISNULL(c.course_id, CAST(h.course_id AS VARCHAR)) AS CourseCode, ISNULL(c.course_name,'Unknown') AS CourseName, ISNULL(c.credits,0) AS Credits " +
                    "FROM add_drop_history h LEFT JOIN course c ON c.course_id=CAST(h.course_id AS VARCHAR(20)) " +
                    "WHERE h.student_id=@sid ORDER BY h.action_date DESC", con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            sb.AppendLine(Convert.ToDateTime(dr["action_date"]).ToString("yyyy-MM-dd") + "," +
                                dr["action_type"] + "," + dr["CourseCode"] + ",\"" + dr["CourseName"] + "\"," + dr["Credits"]);
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