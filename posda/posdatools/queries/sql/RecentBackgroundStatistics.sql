-- Name: RecentBackgroundStatistics
-- Schema: posda_files
-- Columns: ['operation_name', 'worker_priority', 'background_queue_name', 'command_executed', 'num_invocations', 'max_duration', 'avg_duration', 'max_wait', 'avg_wait']
-- Args: ['duration']
-- Tags: ['BackgroundStatistics']
-- Description: Get background job statistics
-- 

select 
  distinct operation_name, worker_priority, background_queue_name,
  command_executed, count(*) as num_invocations, max(duration) as max_duration,
  avg(duration) as avg_duration,
  max(wait_time) as max_wait,
  avg(wait_time) as avg_wait
from (
  select
    operation_name, worker_priority, command_executed,
    when_script_ended - when_script_started as duration,
    when_script_started - when_invoked as wait_time,
    when_invoked, background_queue_name, node_hostname
  from
    work natural join background_subprocess natural join subprocess_invocation
    left join spreadsheet_operation using (operation_name)
  where subprocess_invocation_id in (
    select subprocess_invocation_id
    from work
    where finished and background_queue_name is not null and
    when_invoked > now() - cast(? as interval)
  ) order by when_invoked
) as foo
group by operation_name, worker_priority, background_queue_name, command_executed
order by avg_duration desc