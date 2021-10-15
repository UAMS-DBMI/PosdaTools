-- Name: CreateNewImportEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['import_type', 'import_comment']
-- Tags: ['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda']
-- Description: Insert an Import Event 
-- 

insert into import_event(
  import_type, import_comment, import_time
) values (
  ?, ?, now()
)
returning import_event_id