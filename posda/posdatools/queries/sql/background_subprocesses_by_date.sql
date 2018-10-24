-- Name: background_subprocesses_by_date
-- Schema: posda_queries
-- Columns: ['bkgrnd_id', 'invoc_id', 'operation_name', 'command_line', 'invoking_user', 'when_script_started']
-- Args: ['invoking_user', 'from', 'to']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select 
  background_subprocess_id as bkgrnd_id, subprocess_invocation_id as invoc_id,
  operation_name, command_line, invoking_user, when_script_started
from
  background_subprocess natural left join subprocess_invocation where invoking_user = ?
  and when_script_ended is not null
  and when_script_started > ? and when_script_started < ?
order by when_script_started desc