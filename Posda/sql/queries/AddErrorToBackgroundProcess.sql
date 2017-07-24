-- Name: AddErrorToBackgroundProcess
-- Schema: posda_queries
-- Columns: []
-- Args: ['process_error', 'background_subprocess_id']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Add a error to a background_subprocess  row
-- 
-- used in a background subprocess when an error occurs

update background_subprocess set
  process_error = ?
where
 subprocess_invocation_id = ?
