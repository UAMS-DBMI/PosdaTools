-- Name: GetPosdaFileCreationRoot
-- Schema: posda_files
-- Columns: ['file_storage_root_id', 'root_path']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'used_in_file_import_into_posda']
-- Description: Get the file_storage root for newly created files

select file_storage_root_id, root_path from file_storage_root where current and storage_class = 'created'