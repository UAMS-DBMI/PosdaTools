-- Name: ChangeFileStorageRootIdByFileIdAndOldStorageRootId
-- Schema: posda_files
-- Columns: []
-- Args: ['new_file_storage_root_id', 'old_file_storage_root_id', 'file_id']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get root_path for a file_storage_root
-- 

update
  file_location
set file_storage_root_id = ?
where file_storage_root_id = ?
and file_id = ?