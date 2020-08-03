-- Name: SpreadsheetOperationsStats
-- Schema: posda_queries
-- Columns: ['operation_name', 'operation_type', 'times_invoked', 'first_invoked', 'last_invoked', 'maximum_duration', 'minimum_duration']
-- Args: []
-- Tags: ['queries']
-- Description: Get all named spreadsheet_operations
--

select
  operation_name, operation_type, count(distinct subprocess_invocation_id) as times_invoked,
  min(when_invoked) as first_invoked,
  max(when_invoked) as last_invoked,
  min(when_script_ended - when_script_started) as minimum_duration,
  max(when_script_ended - when_script_started) as maximum_duration
from
  subprocess_invocation natural join background_subprocess
  join spreadsheet_operation using (operation_name)
where
  when_script_started is not null and
  when_script_ended is not null
group by 
  operation_name, operation_type
order by last_invoked desc