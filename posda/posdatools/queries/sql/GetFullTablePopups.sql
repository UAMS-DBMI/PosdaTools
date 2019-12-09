-- Name: GetFullTablePopups
-- Schema: posda_queries
-- Columns: ['popup_button_id', 'name', 'object_class', 'btn_col', 'operation_name', 'command_line', 'input_line_format', 'operation_type']
-- Args: []
-- Tags: ['AllCollections', 'universal']
-- Description: Get a list of configured pop-up buttons


select 
  name, object_class, btn_name as operation_name,
  command_line, input_line_format, operation_type
from
  popup_buttons b, spreadsheet_operation s
where
  s.operation_name = b.btn_name
  and is_full_table
 