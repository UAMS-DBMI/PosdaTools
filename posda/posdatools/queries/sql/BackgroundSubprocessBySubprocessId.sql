-- Name: BackgroundSubprocessBySubprocessId
-- Schema: posda_queries
-- Columns: ['background_subprocess_id', 'subprocess_invocation_id', 'input_rows_processed', 'when_script_started', 'when_background_entered', 'when_script_ended', 'user_to_notify', 'process_error']
-- Args: ['subprocess_invocaton_id']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess']
-- Description: Add a filter to a tab

select 
  background_subprocess_id, subprocess_invocation_id, 
  input_rows_processed,  when_script_started, when_background_entered,
  when_script_ended, user_to_notify, process_error
from 
  background_subprocess
where 
  subprocess_invocation_id = ?
order by when_script_started desc