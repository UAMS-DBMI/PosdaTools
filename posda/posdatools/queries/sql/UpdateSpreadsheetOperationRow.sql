-- Name: UpdateSpreadsheetOperationRow
-- Schema: posda_files
-- Columns: []
-- Args: ['command_line', 'operation_type', 'input_line_format', 'tags', 'can_chain', 'operation_name']
-- Tags: ['operation_maintenance']
-- Description: Update an entry in spreadsheet_operation table


update spreadsheet_operation set
  command_line = ?,
  operation_type = ?,
  input_line_format = ?,
  tags = ?,
  can_chain = ?
where
  operation_name = ?