-- Name: PossiblyRunningBackgroundSubprocesses
-- Schema: posda_queries
-- Columns: ['subprocess_invocation_id', 'background_subprocess_id', 'when_script_started', 'when_background_entered', 'command_line', 'time_in_background', 'background_pid']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess']
-- Description: Add a filter to a tab

select
  subprocess_invocation_id, background_subprocess_id,
  when_script_started, when_background_entered, command_line,
  now()-when_background_entered as time_in_background, background_pid
from
  subprocess_invocation natural join background_subprocess
where
  when_background_entered is not null and when_script_ended is null and
  subprocess_invocation_id != 0 and crash is null
order by subprocess_invocation_id