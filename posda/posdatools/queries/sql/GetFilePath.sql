-- Name: GetFilePath
-- Schema: posda_files
-- Columns: ['path']
-- Args: ['file_id']
-- Tags: ['AllCollections', 'universal', 'public_posda_consistency']
-- Description: Get path to file by id

select
  root_path || '/' || rel_path as path
from
  file_location natural join file_storage_root
where
  file_id = ?