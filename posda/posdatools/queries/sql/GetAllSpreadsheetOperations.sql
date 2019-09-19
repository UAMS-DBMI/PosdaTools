-- Name: GetAllSpreadsheetOperations
-- Schema: posda_queries
-- Columns: ['operation_name', 'command_line', 'operation_type', 'input_line_format', 'tags', 'can_chain']
-- Args: []
-- Tags: ['queries']
-- Description: Get all named spreadsheet_operations


select
  operation_name, command_line, operation_type, input_line_format, tags, can_chain
from
  spreadsheet_operation
