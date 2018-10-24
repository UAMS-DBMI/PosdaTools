-- Name: CreateBackgroundSubprocessError
-- Schema: posda_queries
-- Columns: []
-- Args: ['subprocess_invocation_id', 'input_rows_processed', 'command_executed', 'foreground_pid', 'background_pid', 'when_script_started', 'user_to_notify', 'process_error']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Create row in background_subprocess table with an error in initialization
-- 
-- Used by background subprocess

insert into background_subprocess(
  subprocess_invocation_id,
  input_rows_processed,
  command_executed,
  foreground_pid,
  background_pid,
  when_script_started,
  when_background_entered,
  user_to_notify,
  process_error
) values (
  ?, ?, ?, ?, ?, ?, now(), ?, ?
)