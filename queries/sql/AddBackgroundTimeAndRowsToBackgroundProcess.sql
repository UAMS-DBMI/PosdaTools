-- Name: AddBackgroundTimeAndRowsToBackgroundProcess
-- Schema: posda_queries
-- Columns: None
-- Args: ['input_rows', 'background_pid', 'background_subprocess_id']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: N
-- o
-- n
-- e

update background_subprocess set
  when_background_entered = now(),
  input_rows_processed = ?,
  background_pid = ?
where
  background_subprocess_id = ?

