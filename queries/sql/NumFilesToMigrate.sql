-- Name: NumFilesToMigrate
-- Schema: posda_files
-- Columns: ['num_files']
-- Args: ['storage_class']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get count of files relative to storage root

select
  count(*) as num_files
from
  file_location natural join file_storage_root
where
  storage_class = ?