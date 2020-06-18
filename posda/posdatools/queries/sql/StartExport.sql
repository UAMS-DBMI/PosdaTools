-- Name: StartExport
-- Schema: posda_files
-- Columns: []
-- Args: ['export_event_id']
-- Tags: ['export_event']
-- Description:   Mark an export_event as started
--

update export_event set
  start_time = now(),
  export_status = 'transfering',
  transfer_status_id = null,
  request_pending = false
where
  export_event_id = ?