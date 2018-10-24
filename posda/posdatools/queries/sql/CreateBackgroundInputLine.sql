-- Name: CreateBackgroundInputLine
-- Schema: posda_queries
-- Columns: []
-- Args: ['background_subprocess_id', 'param_index', 'param_value']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Create row in background_input_line table
-- 
-- Used by background subprocess

insert into background_input_line(
  background_subprocess_id,
  line_number,
  line
) values (
  ?, ?, ?
)