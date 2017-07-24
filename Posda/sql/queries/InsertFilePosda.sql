-- Name: InsertFilePosda
-- Schema: posda_files
-- Columns: []
-- Args: ['digest', 'size']
-- Tags: ['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda']
-- Description: Lock the file table in posda_files

insert into file(
  digest, size, processing_priority, ready_to_process
) values ( ?, ?, 1, 'false')
returning file_id
