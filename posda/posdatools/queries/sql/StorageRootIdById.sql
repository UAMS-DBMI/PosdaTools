-- Name: StorageRootIdById
-- Schema: posda_files
-- Columns: ['root_path']
-- Args: ['file_storage_root_id']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get root_path for a file_storage_root
-- 

select root_path from file_storage_root where
file_storage_root_id = ?