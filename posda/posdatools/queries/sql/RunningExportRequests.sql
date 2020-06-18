-- Name: RunningExportRequests
-- Schema: posda_files
-- Columns: ['export_event_id', 'activity_id', 'subprocess_invocation_id', 'export_destination_name', 'creation_time', 'start_time', 'request_pending', 'request_status', 'activity_task_status', 'num_files']
-- Args: []
-- Tags: ['export_event']
-- Description:  Get a list of export events which are "running" I.e. created, started, not ended, and  not dismissed
--

select
  export_event_id, activity_id, subprocess_invocation_id, export_destination_name,
  creation_time, e.start_time, request_pending, request_status, a.status_text as activity_task_status,
  count(distinct file_id) as num_files
from
  export_event e join file_export using(export_event_id)
  join activity_task_status a using(subprocess_invocation_id)
where
  e.start_time is not null and e.end_time is null and e.dismissed_time is null
group by
  export_event_id, activity_id, subprocess_invocation_id, export_destination_name,
  creation_time, e.start_time, request_pending, request_status, activity_task_status