-- Name: GetPopupDefinition
-- Schema: posda_queries
-- Columns: ['command_line', 'input_line_format', 'operation_name', 'operation_type', 'tags']
-- Args: ['operation_name']
-- Tags: ['NotInteractive', 'used_in_process_popup']
-- Description: Get description of popup operation from spreadsheet operation table

select
  command_line, input_line_format,
  operation_name, operation_type,
  tags
from 
  spreadsheet_operation, popup_buttons
where
  operation_name = ?
  and operation_name = btn_name
  and object_class = 'Posda::ProcessPopup'