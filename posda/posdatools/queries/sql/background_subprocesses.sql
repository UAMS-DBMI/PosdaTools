-- Name: background_subprocesses
-- Schema: posda_queries
-- Columns: ['id', 'operation_name', 'command_executed', 'invoking_user', 'when_script_started']
-- Args: ['invoking_user']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select 
  background_subprocess_id as id, 
  operation_name, command_executed, invoking_user, when_script_started
from
  background_subprocess natural left join subprocess_invocation where invoking_user = ?
 and when_script_ended is not null
order by when_script_started desc