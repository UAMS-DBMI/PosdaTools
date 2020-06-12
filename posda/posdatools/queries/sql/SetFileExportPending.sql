-- Name: SetFileExportPending
-- Schema: posda_files
-- Columns: []
-- Args: ['export_event_id', 'file_id']
-- Tags: ['export_event']
-- Description: Mark final status of export_event
--

update file_export set
  when_transferred = null,
  transfer_status = 'pending',
  transfer_status_id = null
where
  export_event_id = ? and file_id = ?