-- Tambahkan kolom semester (available_for)
ALTER TABLE course ADD available_for INT;

-- Tambahkan kolom jadwal (jika belum ada) agar Timetable berfungsi
-- Kita menggunakan VARCHAR untuk waktu agar lebih fleksibel dengan format "09:00"
ALTER TABLE course ADD [day] VARCHAR(20);
ALTER TABLE course ADD start_time VARCHAR(10);
ALTER TABLE course ADD end_time VARCHAR(10);