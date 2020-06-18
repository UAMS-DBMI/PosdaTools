-- Name: CloseImportEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['export_event_id']
-- Tags: ['export_event']
-- Description:  Enter close import_event in export_event
--

update export_event set
  destination_import_event_closed = true
where
  export_event_id = ?