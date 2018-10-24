-- Name: AddCompletionTimeToBackgroundProcess
-- Schema: posda_queries
-- Columns: []
-- Args: ['background_subprocess_id']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Add when_script_ended to a background_subprocess  row
-- 
-- used in a background subprocess when complete

update background_subprocess set
  when_script_ended = now()
where
  background_subprocess_id = ?
