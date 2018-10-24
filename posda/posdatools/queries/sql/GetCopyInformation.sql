-- Name: GetCopyInformation
-- Schema: posda_files
-- Columns: ['status_of_copy', 'pid_of_running_process']
-- Args: ['copy_from_public_id']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

select
  status_of_copy,
  pid_of_running_process
from
  copy_from_public
where copy_from_public_id = ?