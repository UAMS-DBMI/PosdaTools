-- Name: PossiblyRunningSubprocesses
-- Schema: posda_queries
-- Columns: ['subprocess_invocation_id', 'command_line', 'invoking_user', 'when_invoked', 'duration']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess']
-- Description: Add a filter to a tab

select
  subprocess_invocation_id, command_line, invoking_user,
  when_invoked, now() - when_invoked as duration
from
  subprocess_invocation natural left join background_subprocess
where
  when_background_entered is null and subprocess_invocation_id != 0 and
  scrash is null and process_pid is null
order by subprocess_invocation_id