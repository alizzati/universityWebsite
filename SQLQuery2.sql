-- Tambah Pertanyaan
INSERT INTO question (text_qst) VALUES 
('The lecturer explains the material clearly.'),
('The lecturer is well-prepared for the class.'),
('The assessment methods are fair and transparent.');

-- Tambah Dosen
INSERT INTO lecture (lecture_name, lecture_course) VALUES ('Dr. Ahmad Sucipto', 'Computer Science');

-- Tambah Mata Kuliah
INSERT INTO course (course_id, course_name, credits, lecture_id, class_room) VALUES 
('CS101', 'Introduction to Programming', 3, 1, 'Lab 01'),
('CS102', 'Database Systems', 3, 1, 'Room 302');