-- Name: UpdateCopyFromPublic
-- Schema: posda_files
-- Columns: []
-- Args: ['num_file_rows_populated', 'status_of_copy', 'copy_id']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

update copy_from_public
  set when_file_rows_populated = now(),
  num_file_rows_populated = ?,
  status_of_copy = ?
where
  copy_from_public_id = ?