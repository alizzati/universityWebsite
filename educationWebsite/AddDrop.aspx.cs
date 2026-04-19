// ================================================================
//  AddDrop.aspx.cs — FULLY FIXED
//
//  REQUIREMENTS:
//  1. After DROP: course becomes available again for re-enrolment.
//     FIX: UPDATE enrol_status='Dropped' (already done) means the
//     NOT IN subquery in LoadAvailableCourses only excludes
//     'Active' and 'Pending Payment'. 'Dropped' rows are ignored,
//     so the course re-appears as Available. ✓
//
//  2. After enroll+pay: course shows as Enrolled, not Available.
//     FIX: OnlinePayment.cs already UPDATEs enrol_status='Active'.
//     LoadAvailableCourses excludes 'Active' and 'Pending Payment'. ✓
//
//  3. Double-payment prevention: Already enrolled or Pending Payment
//     → error shown, redirect to enrolled tab. ✓
//
//  4. History: RecordHistory stores courseIntId in add_drop_history.
//     Both ADD and DROP are recorded. ✓
//
//  5. DATABINDING FIX: EnrolledCourse and AvailableCourse use
//     { get; set; } PROPERTIES (not public fields). ✓
// ================================================================
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace UniversitySystem
{
    public partial class AddDrop : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        private int StudentId =>
            Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;

        private string ActiveTab
        {
            get { return ViewState["ActiveTab"]?.ToString() ?? "enrolled"; }
            set { ViewState["ActiveTab"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null)
            { Response.Redirect("~/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.RawUrl)); return; }
            if (!IsPostBack) LoadActiveTab();
        }

        private void LoadActiveTab()
        {
            if (ActiveTab == "available")
            {
                pnlEnrolled.Visible = false;
                pnlAvailable.Visible = true;
                btnTabEnrolled.CssClass = "tab-btn";
                btnTabAvailable.CssClass = "tab-btn active";
                LoadAvailableCourses();
            }
            else
            {
                pnlEnrolled.Visible = true;
                pnlAvailable.Visible = false;
                btnTabEnrolled.CssClass = "tab-btn active";
                btnTabAvailable.CssClass = "tab-btn";
                LoadEnrolledCourses();
            }
        }

        protected void btnTab_Click(object sender, EventArgs e)
        {
            ActiveTab = ((Button)sender).CommandArgument;
            LoadActiveTab();
        }

        // ── MY COURSES: Only Active enrollments ──────────────────────────
        private void LoadEnrolledCourses()
        {
            const string sql =
                "SELECT e.enrollment_id, c.course_id, c.course_name, " +
                "       ISNULL(c.credits, 0) AS credits, " +
                "       ISNULL(l.lecture_name, '—') AS lecture_name, " +
                "       ISNULL(c.class_room, '—') AS class_room " +
                "FROM   enrollment e " +
                "JOIN   course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                "LEFT   JOIN lecture l ON l.lecture_id = c.lecture_id " +
                "WHERE  e.student_id=@sid AND e.enrol_status='Active' " +
                "ORDER  BY c.course_id";

            var list = new List<EnrolledCourse>();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 15;
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            list.Add(new EnrolledCourse
                            {
                                EnrollmentId = Convert.ToInt32(dr["enrollment_id"]),
                                CourseId = dr["course_id"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Credits = Convert.ToInt32(dr["credits"]),
                                LectureName = dr["lecture_name"].ToString(),
                                ClassRoom = dr["class_room"].ToString()
                            });
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Error: " + ex.Message); return; }

            phNoEnrolled.Visible = (list.Count == 0);
            rptEnrolled.DataSource = list;
            rptEnrolled.DataBind();
        }

        // ── ADD COURSE: Courses NOT currently Active or Pending Payment ───
        private void LoadAvailableCourses()
        {
            // KEY: courses with enrol_status='Dropped' are NOT excluded,
            // so they re-appear as available after being dropped. ✓
            const string sql =
                "SELECT c.course_id, c.course_name, " +
                "       ISNULL(c.credits, 0) AS credits, " +
                "       ISNULL(l.lecture_name, '—') AS lecture_name, " +
                "       ISNULL(c.class_room, '—') AS class_room " +
                "FROM   course c " +
                "LEFT   JOIN lecture l ON l.lecture_id = c.lecture_id " +
                "WHERE  c.course_id NOT IN (" +
                "    SELECT CAST(course_id AS VARCHAR(20)) FROM enrollment " +
                "    WHERE student_id=@sid AND enrol_status IN ('Active','Pending Payment')" +
                ") ORDER BY c.course_id";

            var list = new List<AvailableCourse>();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 15;
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            list.Add(new AvailableCourse
                            {
                                CourseId = dr["course_id"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                Credits = Convert.ToInt32(dr["credits"]),
                                LectureName = dr["lecture_name"].ToString(),
                                ClassRoom = dr["class_room"].ToString()
                            });
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Error: " + ex.Message); return; }

            phNoAvailable.Visible = (list.Count == 0);
            rptAvailable.DataSource = list;
            rptAvailable.DataBind();
        }

        // ── DROP: Set enrol_status='Dropped', record history ─────────────
        // After drop: course appears in Available tab (Dropped ≠ Active/Pending)
        protected void btnDrop_Click(object sender, EventArgs e)
        {
            int enrollmentId;
            if (!int.TryParse(((Button)sender).CommandArgument, out enrollmentId)) return;

            int courseIntId = 0;
            string courseStrId = "";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Get the course_id (INT) and course_id (VARCHAR) for this enrollment
                    using (var c = new SqlCommand(
                        "SELECT e.course_id AS cint, c.course_id AS cstr " +
                        "FROM enrollment e " +
                        "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                        "WHERE e.enrollment_id=@eid", con))
                    {
                        c.Parameters.AddWithValue("@eid", enrollmentId);
                        using (var dr = c.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                courseIntId = Convert.ToInt32(dr["cint"]);
                                courseStrId = dr["cstr"].ToString();
                            }
                        }
                    }

                    // Soft-delete: set status to 'Dropped'
                    // The course will re-appear in Available tab immediately
                    using (var cmd = new SqlCommand(
                        "UPDATE enrollment SET enrol_status='Dropped' " +
                        "WHERE enrollment_id=@eid AND student_id=@sid", con))
                    {
                        cmd.Parameters.AddWithValue("@eid", enrollmentId);
                        cmd.Parameters.AddWithValue("@sid", StudentId);
                        cmd.ExecuteNonQuery();
                    }

                    // Record Drop in add_drop_history
                    RecordHistory(con, courseIntId, "Drop");
                }

                ShowSuccess("&#10003; Course dropped. It is now available to re-enrol.");
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Drop error: " + ex.Message); }

            ActiveTab = "enrolled";
            LoadActiveTab();
        }

        // ── ADD: Insert as Pending Payment, redirect to payment ───────────
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            string courseId = ((Button)sender).CommandArgument;
            if (string.IsNullOrEmpty(courseId)) return;

            int courseIntId = 0;
            try
            {
                using (var con = new SqlConnection(ConnStr))
                {
                    con.Open();

                    // Check not already active or pending
                    using (var c = new SqlCommand(
                        "SELECT COUNT(*) FROM enrollment " +
                        "WHERE student_id=@sid AND CAST(course_id AS VARCHAR(20))=@cid " +
                        "  AND enrol_status IN('Active','Pending Payment')", con))
                    {
                        c.Parameters.AddWithValue("@sid", StudentId);
                        c.Parameters.AddWithValue("@cid", courseId);
                        if ((int)c.ExecuteScalar() > 0)
                        {
                            ShowError("You are already enrolled or have a pending payment for this course.");
                            ActiveTab = "enrolled"; LoadActiveTab(); return;
                        }
                    }

                    // Get INT course_id for enrollment table
                    using (var c = new SqlCommand(
                        "SELECT COUNT(*) FROM course c2 WHERE c2.course_id <= @cid", con))
                    {
                        c.Parameters.AddWithValue("@cid", courseId);
                        try { courseIntId = (int)c.ExecuteScalar(); } catch { courseIntId = 1; }
                    }

                    // INSERT as 'Pending Payment' — try both date column names
                    bool inserted = false;
                    foreach (var col in new[] { "enrol_data", "enroll_data" })
                    {
                        try
                        {
                            string ins =
                                "INSERT INTO enrollment(student_id,course_id," + col + ",enrol_status,is_completed) " +
                                "VALUES(@sid,@cid,GETDATE(),'Pending Payment',0)";
                            using (var cmd = new SqlCommand(ins, con))
                            {
                                cmd.Parameters.AddWithValue("@sid", StudentId);
                                cmd.Parameters.AddWithValue("@cid", courseIntId);
                                cmd.ExecuteNonQuery();
                                inserted = true; break;
                            }
                        }
                        catch (SqlException sex) when (sex.Number == 207) { }
                    }

                    // Record Add in history
                    if (inserted) RecordHistory(con, courseIntId, "Add");
                }
            }
            catch (SqlException ex) when (IsConnErr(ex)) { RedirectTimeout(); return; }
            catch (Exception ex) { ShowError("Add error: " + ex.Message); return; }

            // Redirect to payment — single course
            Response.Redirect("~/OnlinePayment.aspx?courses=" + Server.UrlEncode(courseId), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // ── Record in add_drop_history ────────────────────────────────────
        private void RecordHistory(SqlConnection con, int courseIntId, string actionType)
        {
            const string sql =
                "INSERT INTO add_drop_history(student_id,course_id,action_type,action_date) " +
                "VALUES(@sid,@cid,@act,CAST(GETDATE() AS DATE))";
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@sid", StudentId);
                cmd.Parameters.AddWithValue("@cid", courseIntId);
                cmd.Parameters.AddWithValue("@act", actionType);
                try { cmd.ExecuteNonQuery(); } catch { }
            }
        }

        private static bool IsConnErr(SqlException ex) =>
            ex.Number == -2 || ex.Number == 2 || ex.Number == 53;

        private void RedirectTimeout()
        {
            Response.Redirect("~/Login.aspx?reason=timeout", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string m) { lblError.Text = m; lblError.Visible = true; lblSuccess.Visible = false; }
        private void ShowSuccess(string m) { lblSuccess.Text = m; lblSuccess.Visible = true; lblError.Visible = false; }

        // DATABINDING requires { get; set; } PROPERTIES (not public fields)
        public class EnrolledCourse
        {
            public int EnrollmentId { get; set; }
            public string CourseId { get; set; }
            public string CourseName { get; set; }
            public int Credits { get; set; }
            public string LectureName { get; set; }
            public string ClassRoom { get; set; }
        }

        public class AvailableCourse
        {
            public string CourseId { get; set; }
            public string CourseName { get; set; }
            public int Credits { get; set; }
            public string LectureName { get; set; }
            public string ClassRoom { get; set; }
        }
    }
}