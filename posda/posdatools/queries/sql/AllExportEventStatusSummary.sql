-- Name: AllExportEventStatusSummary
-- Schema: posda_files
-- Columns: ['export_event_id', 'activity_id', 'export_destination_name', 'export_status', 'creation_time', 'start_time', 'end_time', 'dismissed_time', 'waiting', 'pending', 'success', 'failed_temporary', 'failed_permanent', 'destination_import_event_id', 'destination_import_event_closed']
-- Args: []
-- Tags: ['export_event']
-- Description:   get  summary of transfer statuses from export_event, file_export
--

select
  distinct e.export_event_id, activity_id,
  e.export_destination_name, e.export_status,
  e.creation_time, e.start_time, e.end_time,
  e.dismissed_time,
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
  ) as failed_permanent,
  destination_import_event_id,
  destination_import_event_closed

from export_event e join activity_task_status using(subprocess_invocation_id)
