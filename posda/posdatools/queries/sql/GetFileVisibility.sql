-- Name: GetFileVisibility
-- Schema: posda_files
-- Columns: ['visibility']
-- Args: ['file_id']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get current visibility by file_id
-- 

select distinct visibility from ctp_file where file_id = ?