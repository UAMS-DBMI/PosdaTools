-- Name: MakePosdaFileReadyToProcess
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id']
-- Tags: ['NotInteractive', 'Backlog', 'used_in_file_import_into_posda']
-- Description: Lock the file table in posda_files

update file
  set ready_to_process = true
where file_id = ?