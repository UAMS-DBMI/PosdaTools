-- Name: GetInputFormatForAllCommands
-- Schema: posda_files
-- Columns: ['operation_name', 'input_line_format', 'command_line']
-- Args: []
-- Tags: ['spreadsheet_operations']
-- Description: Get List of visible patients with CTP data

select
  operation_name, input_line_format, command_line
from
  spreadsheet_operation
where input_line_format is not null and operation_type = 'background_process'
  and can_chain