-- Name: GetSpreadsheetOperationByName
-- Schema: posda_files
-- Columns: ['operation_name', 'command_line', 'operation_type', 'input_line_format', 'tags', 'can_chain']
-- Args: ['operation_name']
-- Tags: ['spreadsheet_operations']
-- Description: Get spreadsheet operation by name

select
  operation_name, command_line, operation_type,
  input_line_format, tags, can_chain
from
  spreadsheet_operation
where
  operation_name = ?