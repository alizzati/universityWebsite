using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace UniversitySystem
{
    public partial class TeachingEvaluation : Page
    {
        // ── Exposed to JS ─────────────────────────────────────────────────
        public int EvalPercent { get; private set; }

        // ── StudentId dari Session ────────────────────────────────────────
        private int StudentId
        {
            get
            {
                // Ganti komen ini selepas Login siap:
                // return Convert.ToInt32(Session["StudentId"]);
                return 1; // hardcode untuk development
            }
        }

        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["UniversityDB"].ConnectionString;

        // ════════════════════════════════════════════════════════════════
        //  PAGE LOAD
        // ════════════════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadEvaluationWindow();
                LoadCourses();
            }
            else
            {
                // Kira semula progress untuk gauge JS selepas postback
                LoadProgressOnly();
                LoadCourses();
            }
        }

        // ════════════════════════════════════════════════════════════════
        //  LOAD EVALUATION WINDOW
        // ════════════════════════════════════════════════════════════════
        private void LoadEvaluationWindow()
        {
            bool isOpen = true;
            string startDate = DateTime.Today.ToString("d MMMM yyyy");
            string endDate = DateTime.Today.AddDays(30).ToString("d MMMM yyyy");

            const string sql = @"
                SELECT TOP 1 is_open, start_date, end_date
                FROM   evaluation_window
                ORDER  BY end_date DESC";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            isOpen = Convert.ToBoolean(dr["is_open"]);
                            startDate = Convert.ToDateTime(dr["start_date"]).ToString("d MMMM yyyy");
                            endDate = Convert.ToDateTime(dr["end_date"]).ToString("d MMMM yyyy");
                        }
                    }
                }
            }
            catch { /* fallback to defaults */ }

            lblQuestionerStatus.Text = isOpen
                ? "<span class='badge badge-open'>Open</span>"
                : "<span class='badge badge-closed'>Closed</span>";

            lblStartDate.Text = startDate;
            lblEndDate.Text = endDate;

            LoadProgressOnly();
        }

        // ════════════════════════════════════════════════════════════════
        //  LOAD PROGRESS  — track via enrollment.is_completed (anonymous)
        //  teaching_evaluation tidak ada student_id sesuai ERD
        // ════════════════════════════════════════════════════════════════
        private void LoadProgressOnly()
        {
            int total = 0;
            int completed = 0;

            // Track berdasarkan kolom is_completed di enrollment
            // Ini cara yang betul untuk evaluasi anonym:
            //   - teaching_evaluation: data anonym (tiada student_id)
            //   - enrollment.is_completed: flag untuk UI progress sahaja
            const string sql = @"
                SELECT
                    COUNT(*)                          AS total_courses,
                    SUM(CAST(is_completed AS INT))    AS completed_courses
                FROM   enrollment
                WHERE  student_id   = @sid
                  AND  enrol_status = 'Active'";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            total = Convert.ToInt32(dr["total_courses"]);
                            completed = dr["completed_courses"] == DBNull.Value
                                        ? 0
                                        : Convert.ToInt32(dr["completed_courses"]);
                        }
                    }
                }
            }
            catch { }

            int pct = total > 0 ? (int)Math.Round((double)completed / total * 100) : 0;

            EvalPercent = pct;
            lblPercent.Text = pct + "%";
            lblCompletedCount.Text = completed.ToString();
            lblTotalCount.Text = total.ToString();
        }

        // ════════════════════════════════════════════════════════════════
        //  LOAD COURSES
        // ════════════════════════════════════════════════════════════════
        private void LoadCourses()
        {
            const string sql = @"
                SELECT
                    e.enrollment_id,
                    c.course_id,
                    c.course_name,
                    l.lecture_name    AS lecturer_name,
                    e.is_completed
                FROM   enrollment e
                JOIN   course     c  ON c.course_id  = CAST(e.course_id AS VARCHAR(20))
                JOIN   lecture    l  ON l.lecture_id = c.lecture_id
                WHERE  e.student_id   = @sid
                  AND  e.enrol_status = 'Active'
                ORDER  BY e.is_completed ASC, c.course_id ASC";

            var list = new List<CourseViewModel>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
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
                }
            }
            catch (Exception ex)
            {
                ShowError("Error loading courses: " + ex.Message);
            }

            rptCourses.DataSource = list;
            rptCourses.DataBind();

            LoadQuestions();
        }

        // ════════════════════════════════════════════════════════════════
        //  LOAD QUESTIONS
        // ════════════════════════════════════════════════════════════════
        private void LoadQuestions()
        {
            const string sql = "SELECT question_id, text_qst FROM question ORDER BY question_id";
            var list = new List<QuestionViewModel>();

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    con.Open();
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            list.Add(new QuestionViewModel
                            {
                                QuestionId = Convert.ToInt32(dr["question_id"]),
                                QuestionText = dr["text_qst"].ToString()
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Error loading questions: " + ex.Message);
            }

            rptQuestions.DataSource = list;
            rptQuestions.DataBind();
        }

        // ════════════════════════════════════════════════════════════════
        //  SUBMIT
        // ════════════════════════════════════════════════════════════════
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            // ── 1. Validasi course dipilih ────────────────────────────
            string selectedCourseId = hfSelectedCourseId.Value;
            if (string.IsNullOrEmpty(selectedCourseId) || selectedCourseId == "0")
            {
                ShowError("Please select a course before submitting.");
                return;
            }

            // ── 2. Collect ratings dari Request.Form ──────────────────
            var ratings = new Dictionary<int, int>();
            foreach (string key in Request.Form)
            {
                if (!key.StartsWith("rating_q")) continue;
                string idPart = key.Substring("rating_q".Length);
                int qid, rating;
                if (int.TryParse(idPart, out qid) && int.TryParse(Request.Form[key], out rating))
                    ratings[qid] = rating;
            }

            if (ratings.Count == 0)
            {
                ShowError("Please answer at least one question.");
                return;
            }

            string comment = txtComment.Text.Trim();

            // ── 3. Get enrollment_id untuk UPDATE is_completed ────────
            int enrollmentId = GetEnrollmentId(selectedCourseId);
            if (enrollmentId == 0)
            {
                ShowError("Course already evaluated or enrollment not found.");
                LoadProgressOnly();
                LoadCourses();
                return;
            }

            // ── 4. Save dalam satu transaksi ──────────────────────────
            using (var con = new SqlConnection(ConnStr))
            {
                con.Open();
                using (var tx = con.BeginTransaction())
                {
                    try
                    {
                        // (A) Insert ke teaching_evaluation — ANONYM
                        //     Hanya: course_id, question_id, rating, comment
                        //     TIADA student_id / enrollment_id di sini
                        const string insertSql = @"
                            INSERT INTO teaching_evaluation
                                (course_id, question_id, rating, comment)
                            VALUES
                                (@course_id, @question_id, @rating, @comment)";

                        foreach (var kv in ratings)
                        {
                            var ins = new SqlCommand(insertSql, con, tx);
                            ins.Parameters.AddWithValue("@course_id", selectedCourseId);
                            ins.Parameters.AddWithValue("@question_id", kv.Key);
                            ins.Parameters.AddWithValue("@rating", kv.Value);
                            ins.Parameters.AddWithValue("@comment", comment);
                            ins.ExecuteNonQuery();
                        }

                        // (B) Tandakan sudah evaluate di enrollment
                        //     Hanya tau "dah submit" — TIDAK tau rating apa
                        const string updateSql = @"
                            UPDATE enrollment
                            SET    is_completed = 1
                            WHERE  enrollment_id = @eid
                              AND  student_id    = @sid";

                        var upd = new SqlCommand(updateSql, con, tx);
                        upd.Parameters.AddWithValue("@eid", enrollmentId);
                        upd.Parameters.AddWithValue("@sid", StudentId);
                        upd.ExecuteNonQuery();

                        tx.Commit();

                        ShowSuccess("&#10003; Evaluation submitted successfully! Thank you for your feedback.");
                        txtComment.Text = string.Empty;
                        hfSelectedCourseId.Value = "0";
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        ShowError("Error saving evaluation: " + ex.Message);
                    }
                }
            }

            LoadProgressOnly();
            LoadCourses();
        }

        // ════════════════════════════════════════════════════════════════
        //  GET ENROLLMENT ID  (untuk UPDATE is_completed sahaja)
        //  Cari enrollment yang belum evaluate bagi course ini
        // ════════════════════════════════════════════════════════════════
        private int GetEnrollmentId(string courseId)
        {
            const string sql = @"
                SELECT TOP 1 enrollment_id
                FROM   enrollment
                WHERE  student_id    = @sid
                  AND  CAST(course_id AS VARCHAR(20)) = @cid
                  AND  enrol_status  = 'Active'
                  AND  is_completed  = 0";

            try
            {
                using (var con = new SqlConnection(ConnStr))
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@sid", StudentId);
                    cmd.Parameters.AddWithValue("@cid", courseId);
                    con.Open();
                    var result = cmd.ExecuteScalar();
                    return result != null && result != DBNull.Value
                           ? Convert.ToInt32(result)
                           : 0;
                }
            }
            catch { return 0; }
        }

        // ════════════════════════════════════════════════════════════════
        //  UI HELPERS
        // ════════════════════════════════════════════════════════════════
        private void ShowSuccess(string msg)
        {
            lblSuccess.Text = msg;
            lblSuccess.Visible = true;
            lblError.Visible = false;
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            lblError.Visible = true;
            lblSuccess.Visible = false;
        }

        // ════════════════════════════════════════════════════════════════
        //  VIEW MODELS
        // ════════════════════════════════════════════════════════════════
        public class CourseViewModel
        {
            public int EnrollmentId { get; set; }
            public string CourseId { get; set; }
            public string CourseCode { get; set; }
            public string CourseName { get; set; }
            public string LecturerName { get; set; }
            public bool IsCompleted { get; set; }
        }

        public class QuestionViewModel
        {
            public int QuestionId { get; set; }
            public string QuestionText { get; set; }
        }
    }
}