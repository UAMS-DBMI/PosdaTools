-- Name: background_emails_by_date
-- Schema: posda_queries
-- Columns: ['id', 'button_name', 'operation_name', 'invoking_user', 'when_invoked', 'file_id', 'name']
-- Args: ['invoking_user', 'from', 'to']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select 
  background_subprocess_report_id as id, 
  button_name, operation_name, invoking_user, when_invoked, file_id, name
from background_subprocess_report natural join background_subprocess natural join subprocess_invocation where invoking_user = ? and name = 'Email' and when_invoked > ? and when_invoked < ?
order by when_invoked desc