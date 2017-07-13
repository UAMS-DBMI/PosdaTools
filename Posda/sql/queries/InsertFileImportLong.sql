-- Name: InsertFileImportLong
-- Schema: posda_files
-- Columns: []
-- Args: ['import_event_id', 'file_id', 'rel_path', 'rel_dir', 'file_name']
-- Tags: ['NotInteractive', 'Backlog', 'used_in_file_import_into_posda']
-- Description: Create an import_event

insert into file_import(
  import_event_id, file_id,  rel_path, rel_dir, file_name
) values (
  ?, ?, ?, ?, ?
)
