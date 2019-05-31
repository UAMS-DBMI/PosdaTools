-- Name: DismissActivityTaskStatus
-- Schema: posda_files
-- Columns: []
-- Args: ['dismissed_by', 'activity_id', 'subprocess_invocation_id']
-- Tags: ['NotInteractive', 'Update']
-- Description: Update status_text and expected_completion_time in activity_task_status
-- For use in scripts
-- Not really intended for interactive use
-- 

update activity_task_status set
  dismissed_time = now(),
  dismissed_by = ?
where
  activity_id = ? and
  subprocess_invocation_id = ?