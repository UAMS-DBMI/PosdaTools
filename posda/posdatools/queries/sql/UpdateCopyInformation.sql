-- Name: UpdateCopyInformation
-- Schema: posda_files
-- Columns: []
-- Args: ['status_of_copy', 'pid_of_running_process', 'copy_from_public_id']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

update copy_from_public set 
  status_of_copy = ?,
  pid_of_running_process = ?
where copy_from_public_id = ?