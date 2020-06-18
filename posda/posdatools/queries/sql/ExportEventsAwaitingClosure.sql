-- Name: ExportEventsAwaitingClosure
-- Schema: posda_files
-- Columns: ['export_event_id', 'activity_id', 'export_destination_name', 'protocol', 'export_status', 'destination_import_event_id', 'destination_import_event_closed', 'waiting', 'pending', 'success', 'failed_temporary', 'failed_permanent']
-- Args: []
-- Tags: ['export_event']
-- Description:   get  summary of transfer statuses from export_event, file_export
--

select
  e.export_event_id, activity_id, export_destination_name, 
  protocol, export_status, destination_import_event_id,
  destination_import_event_closed,
  (
    select count(file_id) from file_export f 
    where transfer_status is null and f.export_event_id = e.export_event_id
  ) as waiting,
  (
    select count(file_id) from file_export f
    where e.export_event_id = f.export_event_id and transfer_status = 'pending'
  ) as pending,
  (
    select count(file_id) from file_export f
    where e.export_event_id = f.export_event_id and transfer_status = 'success'
  ) as success,
  (
    select count(file_id) from file_export f
    where e.export_event_id = f.export_event_id and transfer_status = 'failed temporary'
  ) as failed_temporary,
  (
    select count(file_id) from file_export f
    where e.export_event_id = f.export_event_id and transfer_status = 'failed permanent'
  ) as failed_permanent
from
  export_event e natural join export_destination join file_export f using(export_event_id)
  join activity_task_status using(subprocess_invocation_id)
where
  destination_import_event_id is not null
  and (destination_import_event_closed is null or not destination_import_event_closed)
  and f.transfer_status = 'success' and
  e.dismissed_time is null
group by export_event_id, activity_id, export_destination_name, protocol, export_status,
  destination_import_event_id