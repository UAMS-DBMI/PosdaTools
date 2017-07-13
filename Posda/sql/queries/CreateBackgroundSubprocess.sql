-- Name: CreateBackgroundSubprocess
-- Schema: posda_queries
-- Columns: []
-- Args: ['subprocess_invocation_id', 'command_executed', 'foreground_pid', 'user_to_notify']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Create row in background_subprocess table
-- 
-- Used by background subprocess

insert into background_subprocess(
  subprocess_invocation_id,
  command_executed,
  foreground_pid,
  when_script_started,
  user_to_notify
) values (
  ?, ?, ?, now(), ?
)
returning background_subprocess_id