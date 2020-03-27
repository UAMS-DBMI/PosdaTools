-- Name: ExportDaemonRequest
-- Schema: posda_files
-- Columns: []
-- Args: ['request_status', 'export_event_id']
-- Tags: ['export_event']
-- Description: submit a request to Export Daemon
--

update export_event set
  request_status = ?,
  request_pending = true
where export_event_id = ?