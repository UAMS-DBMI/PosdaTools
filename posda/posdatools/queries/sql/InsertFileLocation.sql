-- Name: InsertFileLocation
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'file_storage_root_id', 'rel_path']
-- Tags: ['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda']
-- Description: Lock the file table in posda_files

insert into file_location(
  file_id, file_storage_root_id, rel_path
) values ( ?, ?, ?)