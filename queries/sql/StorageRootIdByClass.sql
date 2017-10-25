-- Name: StorageRootIdByClass
-- Schema: posda_files
-- Columns: ['id']
-- Args: ['storage_class']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get file storage root by storage class
-- 
-- Used in file migration; should return a single row. If not, error in database configuration.

select file_storage_root_id as id from file_storage_root where
storage_class = ?