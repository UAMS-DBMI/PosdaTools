-- Name: CreateSubprocessLine
-- Schema: posda_queries
-- Columns: []
-- Args: ['subprocess_invocation_id', 'line_number', 'line']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Create a row in subprocess_lines table
-- 
-- Used when invoking a spreadsheet operation from a either a button or a spreadsheet 
-- to record data retrieved from subprocess (i.e response displayed on screen)

insert into subprocess_lines(
 subprocess_invocation_id,
 line_number,
 line
) values (
  ?, ?, ?
)