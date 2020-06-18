-- Name: SearchActivityOperations
-- Schema: posda_files
-- Columns: ['operation_name', 'command_line', 'input_line_format']
-- Args: ['op_contains', 'command_contains', 'input_contains']
-- Tags: ['spreadsheet_operations']
-- Description:  Do a search of spreadsheet_operations
--

select
  operation_name, command_line, input_line_format
from
  spreadsheet_operation
where
  operation_name like '%' || ? || '%' or
  command_line like '%' || ? || '%' or
  input_line_format like '%' || ? || '%'