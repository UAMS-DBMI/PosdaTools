-- Name: GetBackgroundButtonsAndCommandAndParams
-- Schema: posda_queries
-- Columns: ['background_button_id', 'operation_name', 'object_class', 'button_text', 'command_line', 'input_line_format']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_process_popup']
-- Description: N
-- o
-- n
-- e
--

select
    background_button_id,
    operation_name,
    object_class,
    button_text,
    command_line,
    input_line_format
from 
  background_buttons
  natural join spreadsheet_operation

