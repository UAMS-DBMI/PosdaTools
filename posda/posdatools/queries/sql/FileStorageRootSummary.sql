-- Name: FileStorageRootSummary
-- Schema: posda_files
-- Columns: ['file_storage_root_id', 'root_path', 'storage_class', 'num_files']
-- Args: []
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get count of files relative to storage root

select 
  distinct file_storage_root_id,
  root_path,
  storage_class,
  count(distinct file_id) as num_files
from
  file_storage_root
  natural join file_location
group by file_storage_root_id, root_path, storage_class;