-- Name: GetBackgroundJobsErrored
-- Schema: posda_files
-- Columns: ['subprocess_invocation_id', 'work_id', 'background_subprocess_id', 'activity_id', 'status', 'input_file_id', 'stdout_file_id', 'stderr_file_id', 'invoking_user', 'since_invocation', 'command_line', 'when_invoked', 'user_to_notify', 'node_hostname', 'background_queue_name']
-- Args: []
-- Tags: ['worker_nodes', 'background_jobs']
-- Description: Work table and related info
-- 

select
  subprocess_invocation_id, work_id, background_subprocess_id, activity_id, 
  status, input_file_id, stdout_file_id, stderr_file_id, invoking_user, 
  now()-when_invoked as since_invocation, command_line,
  when_invoked, user_to_notify, node_hostname, background_queue_name
from
  subprocess_invocation left join work using(subprocess_invocation_id)
  left join background_subprocess using(subprocess_invocation_id)
  left join activity_task_status using(subprocess_invocation_id)
where
  status = 'errored'
order by subprocess_invocation_id desc
   