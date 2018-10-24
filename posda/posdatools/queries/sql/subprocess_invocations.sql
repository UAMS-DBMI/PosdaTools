-- Name: subprocess_invocations
-- Schema: posda_queries
-- Columns: ['command_line', 'when_invoked', 'spreadsheet_uploaded_id']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select command_line, when_invoked, spreadsheet_uploaded_id from subprocess_invocation
where from_spreadsheet
order by when_invoked