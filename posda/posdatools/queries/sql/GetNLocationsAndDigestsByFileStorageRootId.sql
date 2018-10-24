-- Name: GetNLocationsAndDigestsByFileStorageRootId
-- Schema: posda_files
-- Columns: ['file_id', 'digest', 'rel_path']
-- Args: ['file_storage_root_id', 'n']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get root_path for a file_storage_root
-- 

select
  file_id, digest, rel_path
from file_location natural join file
where
  file_storage_root_id = ?
limit ?