-- Name: InsertFileImport
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'file_name']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Create an import_event

insert into file_import(
  import_event_id, file_id,  file_name
) values (
  currval('import_event_import_event_id_seq'),?, ?
)
