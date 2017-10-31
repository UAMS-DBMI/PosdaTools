-- Name: CreateSubprocessInvocationButton
-- Schema: posda_queries
-- Columns: []
-- Args: ['query_invoked_by_dbif_id', 'btn_name', 'command_line', 'invoking_user', 'operation_name']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Create a row in subprocess_invocation table
-- 
-- Used when invoking a spreadsheet operation from a button

insert into subprocess_invocation (
  from_spreadsheet,
  from_button,
  query_invoked_by_dbif_id,
  button_name,
  command_line,
  invoking_user,
  when_invoked,
  operation_name
) values (
  false, true, ?, ?, ?, ?, now(), ?
)
returning subprocess_invocation_id
