-- Name: CreateBackgroundSubprocessParam
-- Schema: posda_queries
-- Columns: []
-- Args: ['background_subprocess_id', 'param_index', 'param_value']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Create row in background_subprocess_params table
-- 
-- Used by background subprocess

insert into background_subprocess_params(
  background_subprocess_id,
  param_index,
  param_value
) values (
  ?, ?, ?
)