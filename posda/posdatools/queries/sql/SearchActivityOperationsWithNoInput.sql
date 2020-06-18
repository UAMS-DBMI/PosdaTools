-- Name: SearchActivityOperationsWithNoInput
-- Schema: posda_files
-- Columns: ['operation_name', 'command_line']
-- Args: ['op_contains', 'command_contains']
-- Tags: ['spreadsheet_operations']
-- Description:  Do a search of spreadsheet_operations
--

select
  operation_name, command_line
from
  spreadsheet_operation
where
  (operation_name like '%' || ? || '%' or
  command_line like '%' || ? || '%') and
  (input_line_format = '' or input_line_format is null)