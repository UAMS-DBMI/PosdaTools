-- Name: CreateSubprocessInvocationSpreadsheet
-- Schema: posda_queries
-- Columns: []
-- Args: ['spreadsheet_uploaded_id', 'command_line', 'invoking_user']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Create a row in subprocess_invocation table
-- 
-- Used when invoking a spreadsheet operation from a spreadsheet

insert into subprocess_invocation(
 from_spreadsheet, from_button,
 spreadsheet_uploaded_id, command_line, invoking_user, when_invoked
) values (
  true, false, ?, ?, ?, now()
)