-- Name: AddBackgroundTimeAndRowsToBackgroundProcess
-- Schema: posda_queries
-- Columns: []
-- Args: ['input_rows', 'background_pid', 'background_subprocess_id']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Add input_rows_processed and background_pid to background_subprocess
-- 
-- Used after fork

update background_subprocess set
  when_background_entered = now(),
  input_rows_processed = ?,
  background_pid = ?
where
  background_subprocess_id = ?
