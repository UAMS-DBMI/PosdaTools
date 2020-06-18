-- Name: ExportEventStatusSummaryById
-- Schema: posda_files
-- Columns: ['export_event_id', 'export_destination_name', 'export_status', 'request_pending', 'request_status', 'status']
-- Args: ['export_event_id']
-- Tags: ['export_event', 'export_name']
-- Description:  get  summary of transfer statuses from export_event, file_export
--

select
  distinct e.export_event_id, e.end_time, e.export_destination_name,
  e.export_status, e.request_pending, e.request_status,
  'W: ' || (
    select count(file_id) from file_export f 
    where transfer_status is null and f.export_event_id = e.export_event_id
  ) || ', P: ' ||
  (
    select count(file_id) from file_export f
    where e.export_event_id = f.export_event_id and transfer_status = 'pending'
  ) || ', S: ' ||
  (
    select count(file_id) from file_export f
    where e.export_event_id = f.export_event_id and transfer_status = 'success'
  ) || ', Ft: ' ||
  (
    select count(file_id) from file_export f
    where e.export_event_id = f.export_event_id and transfer_status = 'failed temporary'
  ) || ', Fp: ' ||
  (
    select count(file_id) from file_export f
    where e.export_event_id = f.export_event_id and transfer_status = 'failed permanent'
  ) as status

from export_event e
where e.export_event_id = ?