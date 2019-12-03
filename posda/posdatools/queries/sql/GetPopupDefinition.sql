-- Name: GetPopupDefinition
-- Schema: posda_queries
-- Columns: ['command_line', 'input_line_format', 'operation_name', 'operation_type', 'tags']
-- Args: ['operation_name']
-- Tags: ['NotInteractive', 'used_in_process_popup']
-- Description: N
-- o
-- n
-- e
--


select
  command_line, input_line_format,
  operation_name, operation_type,
  tags
from 
  spreadsheet_operation
where
  operation_name = ?
