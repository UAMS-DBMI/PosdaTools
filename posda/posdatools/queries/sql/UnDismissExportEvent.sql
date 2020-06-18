-- Name: UnDismissExportEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['export_event_id']
-- Tags: []
-- Description:   Dismiss an export event
--

update export_event set
  dismissed_time = null
where
  export_event_id = ?