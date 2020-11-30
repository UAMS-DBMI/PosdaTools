-- Name: GetBackgroundJobsAll
-- Schema: posda_files
-- Columns: ['work_id', 'subprocess_invocation_id', 'activity_id', 'command_line', 'invoking_user', 'when_script_started', 'when_script_ended', 'user_to_notify', 'input_file_id', 'status', 'stdout_file_id', 'stderr_file_id']
-- Args: []
-- Tags: ['worker_nodes']
-- Description: Work table and related info
-- 

select
  work_id, subprocess_invocation_id, activity_id, command_line,
  invoking_user, when_script_started, when_script_ended,
  user_to_notify,input_file_id, status, stdout_file_id, stderr_file_id
from
  work natural join subprocess_invocation
  natural left join background_subprocess
  natural left join activity_task_status

   