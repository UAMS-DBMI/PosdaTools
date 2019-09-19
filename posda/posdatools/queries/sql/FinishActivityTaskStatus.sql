-- Name: FinishActivityTaskStatus
-- Schema: posda_files
-- Columns: []
-- Args: ['status_text', 'activity_id', 'subprocess_invocation_id']
-- Tags: ['NotInteractive', 'Update']
-- Description: Update status_text and end_timee in activity_task_status
-- For use in scripts
-- Not really intended for interactive use
-- 

update activity_task_status set
  status_text = ?,
  expected_remaining_time = null,
  dismissed_time = null,
  end_time = now(),
  last_updated = now()
where
  activity_id = ? and
  subprocess_invocation_id = ?