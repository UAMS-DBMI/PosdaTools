-- Name: GetFilePathAndModality
-- Schema: posda_files
-- Columns: ['path', 'modality']
-- Args: ['file_id']
-- Tags: ['AllCollections', 'universal', 'public_posda_consistency']
-- Description: Get path to file by id

select
  root_path || '/' || rel_path as path, modality
from
  file_location natural join file_storage_root join file_series using(file_id)
where
  file_id = ?