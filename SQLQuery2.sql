-- 1. Hapus Constraint Foreign Key terlebih dahulu
ALTER TABLE teaching_evaluation 
DROP CONSTRAINT IF EXISTS FK_te_enrollment;
GO

-- 2. Hapus Index
DROP INDEX IF EXISTS IX_te_enrollment ON teaching_evaluation;
GO

-- 3. Hapus kolom enrollment_id
ALTER TABLE teaching_evaluation 
DROP COLUMN IF EXISTS enrollment_id;
GO