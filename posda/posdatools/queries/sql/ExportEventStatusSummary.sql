-- Name: ExportEventStatusSummary
-- Schema: posda_files
-- Columns: ['export_event_id', 'waiting', 'pending', 'success', 'failed_temporary', 'failed_permanent']
-- Args: []
-- Tags: []
-- Description: get  summary of transfer statuses from export_event, file_export
--

select
  distinct e.export_event_id, 
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

from export_event e