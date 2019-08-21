-- Name: CreateSpreadsheetOperation
-- Schema: posda_queries
-- Columns: []
-- Args: ['operation_name', 'command_line', 'operation_type', 'input_line_format', 'tags', 'can_chain']
-- Tags: ['queries']
-- Description: Create a new spreadsheet_operation
--

insert into spreadsheet_operation(
  operation_name, command_line, operation_type, input_line_format, tags, can_chain
) values (
  ?, ?, ?, ?, ?, ?
)