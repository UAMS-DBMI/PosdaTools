-- Name: GetStudyByFileId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['file_id']
-- Tags: ['bills_test', 'posda_db_populate']
-- Description: Add a filter to a tab

select file_id from file_study where file_id = ?