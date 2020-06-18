-- Name: UpdateFileExportStatus
-- Schema: posda_files
-- Columns: []
-- Args: ['transfer_status', 'export_event_id', 'file_id']
-- Tags: ['export_event']
-- Description:  Mark final status of export_event
--

update file_export set
  when_transferred = now(),
  transfer_status = ?,
  transfer_status_id = null
where
  export_event_id = ? and file_id = ?