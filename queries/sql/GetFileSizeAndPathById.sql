-- Name: GetFileSizeAndPathById
-- Schema: posda_files
-- Columns: ['path', 'size']
-- Args: ['file_id']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select
  root_path || '/' || rel_path as path,
  size
from
  file_storage_root natural join file_location natural join file 
where file_id = ?