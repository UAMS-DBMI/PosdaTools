-- Name: NotOutdatedOperations
-- Schema: posda_files
-- Columns: ['operation_name', 'command_line', 'input_line_format', 'outdated']
-- Args: []
-- Tags: ['background_operations']
-- Description: List of not outdated operations
-- 

select
  operation_name, command_line, input_line_format, outdated
from
  spreadsheet_operation
where
  not outdated