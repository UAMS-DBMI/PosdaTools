-- Name: RecentBackgroundProgress
-- Schema: posda_files
-- Columns: ['work_id', 'status', 'status_text', 'operation_name', 'invoking_user', 'run_time']
-- Args: ['interval']
-- Tags: ['BackgroundStatistics']
-- Description: Get background job statistics
-- 

select
  work_id, status, status_text, operation_name, invoking_user,
  when_invoked, now() - when_script_started as run_time
from
  work natural join subprocess_invocation natural join background_subprocess
  natural join activity_task_status
where
  status = 'running' and
  when_invoked > now() - cast(? as interval)
order by work_id desc;