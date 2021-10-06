-- Name: RecentBackgroundSummary
-- Schema: posda_files
-- Columns: ['operation_name', 'worker_priority', 'command_executed', 'duration', 'wait_time', 'when_invoked', 'background_queue_name', 'node_hostname']
-- Args: ['interval']
-- Tags: ['BackgroundStatistics']
-- Description: Get background job statistics
-- 

select
    operation_name, worker_priority, command_executed,
    when_script_ended - when_script_started as duration,
    when_script_started - when_invoked as wait_time,
    when_invoked, background_queue_name, node_hostname
from
    work natural join background_subprocess natural join subprocess_invocation
    left join spreadsheet_operation using (operation_name)
where
   finished and background_queue_name is not null and
   when_invoked > now() - cast(? as interval)
order by when_invoked
