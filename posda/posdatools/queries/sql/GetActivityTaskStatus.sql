-- Name: GetActivityTaskStatus
-- Schema: posda_files
-- Columns: ['operation_name', 'start_time', 'last_updated', 'status_text', 'expected_remaining_time', '  end_time']
-- Args: ['activity_id']
-- Tags: ['Insert', 'NotInteractive']
-- Description: Insert Initial Patient Status
-- For use in scripts
-- Not really intended for interactive use
-- 

select
  subprocess_invocation_id,
  operation_name,
  start_time,
  last_updated,
  status_text,
  expected_remaining_time,
  end_time
from
  activity_task_status natural join subprocess_invocation
where
  activity_id = ? and dismissed_time is null