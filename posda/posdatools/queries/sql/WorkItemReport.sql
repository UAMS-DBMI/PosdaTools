-- Name: WorkItemReport
-- Schema: posda_files
-- Columns: ['work_id', 'status', 'status_text', 'operation_name', 'invoking_user', 'since_invoked', 'wait_time', 'since_started', 'duration', 'since_ended']
-- Args: ['work_id']
-- Tags: ['BackgroundStatistics']
-- Description: Get background job statistics
-- 

select
  work_id, status, status_text, operation_name, invoking_user,
  when_invoked, now() - when_invoked as since_invoked,
  when_script_started - when_invoked as wait_time,
  now() - when_script_started as since_started,
  when_script_ended - when_script_started as duration,
  now() - when_script_ended as since_ended
from
  work natural join subprocess_invocation natural join background_subprocess
  natural join activity_task_status
where
 work_id = ?
