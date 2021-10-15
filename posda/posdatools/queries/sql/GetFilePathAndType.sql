-- Name: GetFilePathAndType
-- Schema: posda_files
-- Columns: ['path', 'file_type']
-- Args: ['file_id']
-- Tags: ['AllCollections', 'universal', 'public_posda_consistency']
-- Description: Get path to file by id
-- 

select
  root_path || '/' || rel_path as path, file_type
from
  file_location natural join file_storage_root natural join file
where
  file_id = ?