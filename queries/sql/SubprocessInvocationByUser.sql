-- Name: SubprocessInvocationByUser
-- Schema: posda_queries
-- Columns: ['subprocess_invocation_id', 'background_subprocess_id', 'spreadsheet_uploaded_id', 'query_invoked_by_dbif_id', 'button_name', 'invoking_user', 'when_invoked', 'operation_name', 'num_lines']
-- Args: ['invoking_user']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'subprocess']
-- Description: Add a filter to a tab

select 
  distinct subprocess_invocation_id, 
  background_subprocess_id, spreadsheet_uploaded_id, query_invoked_by_dbif_id,
  button_name, invoking_user, when_invoked, operation_name,
  max(line_number) as num_lines
from 
  subprocess_invocation natural left join subprocess_lines
  natural left join background_subprocess
where 
  invoking_user = ?
group by 
  subprocess_invocation_id, 
  background_subprocess_id, spreadsheet_uploaded_id, query_invoked_by_dbif_id,
  button_name, invoking_user, when_invoked, operation_name
order by when_invoked desc