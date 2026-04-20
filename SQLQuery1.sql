-- ============================================================
-- SCRIPT PERBAIKAN DATABASE
-- Masalah: semua PRIMARY KEY tidak punya IDENTITY(1,1)
-- sehingga INSERT gagal karena nilai NULL tidak diperbolehkan
-- ============================================================

-- Urutan DROP harus dari tabel yang punya FK dulu
-- agar tidak error constraint violation

-- LANGKAH 1: Drop semua tabel (urutan penting!)
IF OBJECT_ID('teaching_evaluation', 'U') IS NOT NULL DROP TABLE teaching_evaluation;
IF OBJECT_ID('add_drop_history',    'U') IS NOT NULL DROP TABLE add_drop_history;
IF OBJECT_ID('payment',             'U') IS NOT NULL DROP TABLE payment;
IF OBJECT_ID('enrollment',          'U') IS NOT NULL DROP TABLE enrollment;
IF OBJECT_ID('contact_us',          'U') IS NOT NULL DROP TABLE contact_us;
IF OBJECT_ID('evaluation_window',   'U') IS NOT NULL DROP TABLE evaluation_window;
IF OBJECT_ID('course',              'U') IS NOT NULL DROP TABLE course;
IF OBJECT_ID('lecture',             'U') IS NOT NULL DROP TABLE lecture;
IF OBJECT_ID('question',            'U') IS NOT NULL DROP TABLE question;
IF OBJECT_ID('student',             'U') IS NOT NULL DROP TABLE student;

-- LANGKAH 2: Buat ulang semua tabel dengan IDENTITY yang benar

-- 1. Tabel Student
CREATE TABLE student (
    student_id   INT           IDENTITY(1,1) PRIMARY KEY,
    std_name     VARCHAR(255),
    std_email    VARCHAR(255),
    std_password VARCHAR(255),
    std_phone    VARCHAR(20),
    std_address  NVARCHAR(MAX)
);

-- 2. Tabel Lecture
CREATE TABLE lecture (
    lecture_id     INT          IDENTITY(1,1) PRIMARY KEY,
    lecture_name   VARCHAR(255),
    lecture_course VARCHAR(255)
);

-- 3. Tabel Question
CREATE TABLE question (
    question_id INT          IDENTITY(1,1) PRIMARY KEY,
    text_qst    NVARCHAR(MAX)
);

-- 4. Tabel Course
--    course_id     = INT IDENTITY (PK, auto-increment)
--    course_code   = VARCHAR (kode tampilan seperti "CS101")
--
--    PENTING: Di kode C# kita pakai course_id (INT) untuk enrollment & payment,
--    dan course_code (VARCHAR) untuk tampilan ke user.
CREATE TABLE course (
    course_id      INT           IDENTITY(1,1) PRIMARY KEY,
    course_code    VARCHAR(20),
    course_name    VARCHAR(255),
    lecture_id     INT,
    fee            DECIMAL(10,2),
    credits        INT,
    class_room     VARCHAR(50),
    available_for  VARCHAR(100),
    day            VARCHAR(20),
    start_time     TIME,
    end_time       TIME,
    CONSTRAINT FK_Course_Lecture FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id)
);

-- 5. Tabel Enrollment
--    enrollment_id = IDENTITY (auto-generate, tidak perlu diisi manual)
--    course_id     = INT FK ke course.course_id
CREATE TABLE enrollment (
    enrollment_id INT      IDENTITY(1,1) PRIMARY KEY,
    student_id    INT      NOT NULL,
    course_id     INT      NOT NULL,
    is_completed  BIT      DEFAULT 0,
    enrol_status  VARCHAR(50),
    enrol_data    DATETIME DEFAULT GETDATE(),
    is_evaluated  BIT      DEFAULT 0,
    CONSTRAINT FK_Enroll_Student FOREIGN KEY (student_id) REFERENCES student(student_id),
    CONSTRAINT FK_Enroll_Course  FOREIGN KEY (course_id)  REFERENCES course(course_id)
);

-- 6. Tabel Payment
--    payment_id = IDENTITY (auto-generate)
--    course_id  = INT FK ke course.course_id
CREATE TABLE payment (
    payment_id  INT           IDENTITY(1,1) PRIMARY KEY,
    student_id  INT           NOT NULL,
    course_id   INT           NOT NULL,
    bank_name   VARCHAR(100),
    amount      DECIMAL(10,2),
    status      VARCHAR(50),
    created_at  DATETIME      DEFAULT GETDATE(),
    CONSTRAINT FK_Payment_Student FOREIGN KEY (student_id) REFERENCES student(student_id),
    CONSTRAINT FK_Payment_Course  FOREIGN KEY (course_id)  REFERENCES course(course_id)
);

-- 7. Tabel Add Drop History
--    course_id = INT FK ke course.course_id (bukan enrollment)
CREATE TABLE add_drop_history (
    history_id  INT           IDENTITY(1,1) PRIMARY KEY,
    student_id  INT           NOT NULL,
    course_id   INT           NOT NULL,
    action_type VARCHAR(10),
    action_date DATE          DEFAULT CAST(GETDATE() AS DATE),
    CONSTRAINT FK_History_Student FOREIGN KEY (student_id) REFERENCES student(student_id),
    CONSTRAINT FK_History_Course  FOREIGN KEY (course_id)  REFERENCES course(course_id)
);

-- 8. Tabel Contact Us
CREATE TABLE contact_us (
    message_id     INT           IDENTITY(1,1) PRIMARY KEY,
    student_id     INT,
    subject_msg    VARCHAR(255),
    body_msg       NVARCHAR(MAX),
    created_at_msg DATETIME      DEFAULT GETDATE(),
    CONSTRAINT FK_Contact_Student FOREIGN KEY (student_id) REFERENCES student(student_id)
);

-- 9. Tabel Teaching Evaluation
CREATE TABLE teaching_evaluation (
    evaluation_id INT           IDENTITY(1,1) PRIMARY KEY,
    course_id     INT,
    question_id   INT,
    rating        INT,
    comment       NVARCHAR(MAX),
    CONSTRAINT FK_Eval_Course    FOREIGN KEY (course_id)    REFERENCES course(course_id),
    CONSTRAINT FK_Eval_Question  FOREIGN KEY (question_id)  REFERENCES question(question_id)
);

-- 10. Tabel Evaluation Window (dari screenshot DB)
CREATE TABLE evaluation_window (
    window_id   INT      IDENTITY(1,1) PRIMARY KEY,
    is_open     BIT      DEFAULT 0,
    start_date  DATETIME,
    end_date    DATETIME
);

-- ============================================================
-- VERIFIKASI: cek semua tabel sudah dibuat
-- ============================================================
SELECT
    t.name        AS table_name,
    c.name        AS column_name,
    c.is_identity AS has_identity
FROM sys.tables t
JOIN sys.columns c ON c.object_id = t.object_id
WHERE t.name IN ('enrollment','payment','course','add_drop_history','student')
  AND c.column_id = 1
ORDER BY t.name;