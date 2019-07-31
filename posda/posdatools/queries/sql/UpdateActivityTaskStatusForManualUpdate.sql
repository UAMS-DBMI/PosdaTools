-- Name: UpdateActivityTaskStatusForManualUpdate
-- Schema: posda_files
-- Columns: []
-- Args: ['status_text', 'activity_id', 'subprocess_invocation_id']
-- Tags: ['NotInteractive', 'Update']
-- Description: Update status_text and expected_completion_time in activity_task_status
-- For use in scripts
-- Not really intended for interactive use
--

update activity_task_status set
  status_text = ?,
  last_updated = now(),
  dismissed_time = null,
  dismissed_by = null,
  manual_update = true
where
  activity_id = ? and
  subprocess_invocation_id = ?
