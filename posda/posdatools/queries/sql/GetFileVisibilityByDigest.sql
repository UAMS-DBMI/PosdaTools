-- Name: GetFileVisibilityByDigest
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['digest']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get current visibility by file_id
-- 

select distinct file_id,  visibility from file natural join ctp_file where digest = ?