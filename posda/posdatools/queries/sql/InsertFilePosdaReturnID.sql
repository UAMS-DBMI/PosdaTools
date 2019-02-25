-- Name: InsertFilePosdaReturnID
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['digest', 'size']
-- Tags: ['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda']
-- Description: Insert a file without locking the table

insert into file( digest, size, processing_priority, ready_to_process) values ( ?, ?, 1, false) on conflict  do nothing returning file_id;