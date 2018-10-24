-- Name: FileStorageRootSummaryExtended
-- Schema: posda_files
-- Columns: ['file_storage_root_id', 'root_path', 'storage_class', 'num_files', 'total_bytes']
-- Args: []
-- Tags: ['used_in_file_import_into_posda', 'bills_test']
-- Description: Get count of files relative to storage root

select 
  distinct file_storage_root_id,
  root_path,
  storage_class,
  count(distinct file_id) as num_files,
  sum(size) as total_bytes
from
  file_storage_root
  natural join file_location
  natural join file
group by file_storage_root_id, root_path, storage_class;