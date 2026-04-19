using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class TeachingEvaluation : Page
    {
        public int EvalPercent { get; private set; }
        private int StudentId => Session["StudentId"] != null ? Convert.ToInt32(Session["StudentId"]) : 0;
        private string ConnStr => ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["StudentId"] == null) { Response.Redirect("~/Login.aspx"); return; }
            if (!IsPostBack) { LoadEvaluationWindow(); LoadCourses(); }
            else { LoadProgressOnly(); LoadCourses(); }
        }

        private void LoadEvaluationWindow()
        {
            bool isOpen = true;
            string startDate = DateTime.Today.ToString("d MMMM yyyy");
            string endDate = DateTime.Today.AddDays(30).ToString("d MMMM yyyy");
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT TOP 1 is_open, start_date, end_date FROM evaluation_window ORDER BY end_date DESC", con))
                {
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        if (dr.Read()) { isOpen = Convert.ToBoolean(dr["is_open"]); startDate = Convert.ToDateTime(dr["start_date"]).ToString("d MMMM yyyy"); endDate = Convert.ToDateTime(dr["end_date"]).ToString("d MMMM yyyy"); }
                }
            }
            catch { }
            lblQuestionerStatus.Text = isOpen ? "<span class='badge badge-open'>Open</span>" : "<span class='badge badge-closed'>Closed</span>";
            lblStartDate.Text = startDate; lblEndDate.Text = endDate;
            LoadProgressOnly();
        }

        private void LoadProgressOnly()
        {
            int total = 0, completed = 0;
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT COUNT(*) AS total_courses, SUM(CAST(is_completed AS INT)) AS completed_courses FROM enrollment WHERE student_id=@sid AND enrol_status='Active'", con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId); con.Open();
                    using (var dr = cmd.ExecuteReader())
                        if (dr.Read()) { total = Convert.ToInt32(dr["total_courses"]); completed = dr["completed_courses"] == DBNull.Value ? 0 : Convert.ToInt32(dr["completed_courses"]); }
                }
            }
            catch { }
            int pct = total > 0 ? (int)Math.Round((double)completed / total * 100) : 0;
            EvalPercent = pct; lblPercent.Text = pct + "%"; lblCompletedCount.Text = completed.ToString(); lblTotalCount.Text = total.ToString();
        }

        private void LoadCourses()
        {
            const string sql =
                "SELECT e.enrollment_id, c.course_id, c.course_name, " +
                "ISNULL(l.lecture_name,'—') AS lecturer_name, e.is_completed " +
                "FROM enrollment e " +
                "JOIN course c ON c.course_id = CAST(e.course_id AS VARCHAR(20)) " +
                "LEFT JOIN lecture l ON l.lecture_id = c.lecture_id " +
                "WHERE e.student_id=@sid AND e.enrol_status='Active' " +
                "ORDER BY e.is_completed ASC, c.course_id ASC";
            var list = new List<CourseViewModel>();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId); con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            list.Add(new CourseViewModel
                            {
                                EnrollmentId = Convert.ToInt32(dr["enrollment_id"]),
                                CourseId = dr["course_id"].ToString(),
                                CourseCode = dr["course_id"].ToString(),
                                CourseName = dr["course_name"].ToString(),
                                LecturerName = dr["lecturer_name"].ToString(),
                                IsCompleted = Convert.ToBoolean(dr["is_completed"])
                            });
                }
            }
            catch (Exception ex) { ShowError("Error loading courses: " + ex.Message); }
            rptCourses.DataSource = list; rptCourses.DataBind();
            LoadQuestions();
        }

        private void LoadQuestions()
        {
            var list = new List<QuestionViewModel>();
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT question_id, text_qst FROM question ORDER BY question_id", con))
                {
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            list.Add(new QuestionViewModel { QuestionId = Convert.ToInt32(dr["question_id"]), QuestionText = dr["text_qst"].ToString() });
                }
            }
            catch (Exception ex) { ShowError("Error loading questions: " + ex.Message); }
            rptQuestions.DataSource = list; rptQuestions.DataBind();
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string selectedCourseId = hfSelectedCourseId.Value;
            if (string.IsNullOrEmpty(selectedCourseId) || selectedCourseId == "0") { ShowError("Please select a course."); return; }
            var ratings = new Dictionary<int, int>();
            foreach (string key in Request.Form)
            {
                if (!key.StartsWith("rating_q")) continue;
                int qid, rating;
                if (int.TryParse(key.Substring("rating_q".Length), out qid) && int.TryParse(Request.Form[key], out rating))
                    ratings[qid] = rating;
            }
            if (ratings.Count == 0) { ShowError("Please answer at least one question."); return; }
            int enrollmentId = GetEnrollmentId(selectedCourseId);
            if (enrollmentId == 0) { ShowError("Course already evaluated or enrollment not found."); LoadProgressOnly(); LoadCourses(); return; }
            string comment = txtComment.Text.Trim();
            using (var con = new SqlConnection(ConnStr))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                {
                    try
                    {
                        foreach (var kv in ratings)
                        {
                            using (var cmd = new SqlCommand("INSERT INTO teaching_evaluation(course_id,question_id,rating,comment) VALUES(@cid,@qid,@rating,@comment)", con, tx))
                            { cmd.Parameters.AddWithValue("@cid", selectedCourseId); cmd.Parameters.AddWithValue("@qid", kv.Key); cmd.Parameters.AddWithValue("@rating", kv.Value); cmd.Parameters.AddWithValue("@comment", comment); cmd.ExecuteNonQuery(); }
                        }
                        using (var upd = new SqlCommand("UPDATE enrollment SET is_completed=1 WHERE enrollment_id=@eid AND student_id=@sid", con, tx))
                        { upd.Parameters.AddWithValue("@eid", enrollmentId); upd.Parameters.AddWithValue("@sid", StudentId); upd.ExecuteNonQuery(); }
                        tx.Commit();
                        ShowSuccess("&#10003; Evaluation submitted! Thank you."); txtComment.Text = ""; hfSelectedCourseId.Value = "0";
                    }
                    catch (Exception ex) { tx.Rollback(); ShowError("Error: " + ex.Message); }
                }
            }
            LoadProgressOnly(); LoadCourses();
        }

        private int GetEnrollmentId(string courseId)
        {
            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand("SELECT TOP 1 enrollment_id FROM enrollment WHERE student_id=@sid AND CAST(course_id AS VARCHAR(20))=@cid AND enrol_status='Active' AND is_completed=0", con))
                { cmd.Parameters.AddWithValue("@sid", StudentId); cmd.Parameters.AddWithValue("@cid", courseId); con.Open(); var r = cmd.ExecuteScalar(); return r != null && r != DBNull.Value ? Convert.ToInt32(r) : 0; }
            }
            catch { return 0; }
        }

        private void ShowSuccess(string msg) { lblSuccess.Text = msg; lblSuccess.Visible = true; lblError.Visible = false; }
        private void ShowError(string msg) { lblError.Text = msg; lblError.Visible = true; lblSuccess.Visible = false; }

        public class CourseViewModel { public int EnrollmentId { get; set; } public string CourseId { get; set; } public string CourseCode { get; set; } public string CourseName { get; set; } public string LecturerName { get; set; } public bool IsCompleted { get; set; } }
        public class QuestionViewModel { public int QuestionId { get; set; } public string QuestionText { get; set; } }
    }
}