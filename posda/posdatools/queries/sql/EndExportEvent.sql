-- Name: EndExportEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['export_status_type', 'export_event_id']
-- Tags: ['export_event']
-- Description: Mark final status of export_event
--

update export_event set
  end_time = now(),
  export_status = ?,
  transfer_status_id = null,
  request_pending = false
where
  export_event_id = ?