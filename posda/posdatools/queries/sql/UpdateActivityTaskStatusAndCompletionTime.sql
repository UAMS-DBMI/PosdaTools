-- Name: UpdateActivityTaskStatusAndCompletionTime
-- Schema: posda_files
-- Columns: []
-- Args: ['status_text', 'expected_completion_time', 'activity_id', 'subprocess_invocation_id']
-- Tags: ['NotInteractive', 'Update']
-- Description: Update status_text and expected_completion_time in activity_task_status
-- For use in scripts
-- Not really intended for interactive use
-- 

update activity_task_status set
  status_text = ?,
  expected_remaining_time = ?,
  last_updated = now(),
  dismissed_time = null,
  dismissed_by = null
where
  activity_id = ? and
  subprocess_invocation_id = ?