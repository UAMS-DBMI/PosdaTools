-- Name: PathAndDigestByFileId
-- Schema: posda_files
-- Columns: ['file_path', 'digest']
-- Args: ['file_id']
-- Tags: ['file_info']
-- Description: Get digest and path to file from file_id
-- 

select
  root_path || '/' || rel_path as file_path, digest
from
  file natural join file_location natural join file_storage_root
where
  file_id = ?