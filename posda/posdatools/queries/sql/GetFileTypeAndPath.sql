-- Name: GetFileTypeAndPath
-- Schema: posda_files
-- Columns: ['file_type']
-- Args: ['file_id']
-- Tags: ['nifti']
-- Description: Get file_type of a file by file_id
-- 

select
  file_type, root_path || '/'|| rel_path as path
from
  file natural join file_location natural join file_storage_root
where file_id = ?