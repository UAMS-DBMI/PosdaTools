-- Name: ExportEventFileTransferStatusByExportEvent
-- Schema: posda_files
-- Columns: ['when_transferred', 'transfer_status']
-- Args: ['export_event_id']
-- Tags: ['export_event']
-- Description: get  summary of transfer statuses from export_event, file_export
--

select
  distinct when_transferred, transfer_status, count(*)
from
  file_export
where export_event_id =?
group by when_transferred, transfer_status