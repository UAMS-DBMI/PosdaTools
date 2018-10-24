-- Name: GetCopyFromPublicInfo
-- Schema: posda_files
-- Columns: ['copy_from_public_id', 'when_row_created', 'who', 'why', 'num_files', 'status_of_copy', 'pid_of_running_process']
-- Args: []
-- Tags: ['bills_test', 'copy_from_public', 'public_posda_consistency']
-- Description: Add a filter to a tab

select
  copy_from_public_id,
  when_row_created,
  who,
  why, 
  num_file_rows_populated as num_files,
  status_of_copy,
  pid_of_running_process
from
  copy_from_public
