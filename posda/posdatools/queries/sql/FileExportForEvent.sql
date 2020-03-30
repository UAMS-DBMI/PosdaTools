-- Name: FileExportForEvent
-- Schema: posda_files
-- Columns: ['file_id', 'null_if_no_disp_parms', 'when_queued', 'when_transferred', 'transfer_status', 'transfer_status_message', 'offset_days', 'uid_root', 'batch']
-- Args: ['export_event_id']
-- Tags: ['export_event']
-- Description: Get list of files with status and disposition params by export_event_id
--

select
  fe.file_id as file_id, ed.file_id as null_if_no_disp_parms, 
  when_queued, when_transferred, transfer_status, transfer_status_message,
  offset_days, uid_root, batch
from
  file_export fe natural left join transfer_status natural left join export_file_dispositions_params ed
where export_event_id = ?