-- Name: SetDestinationImportEventId
-- Schema: posda_files
-- Columns: []
-- Args: ['destination_import_event_id', 'export_event_id']
-- Tags: ['export_event']
-- Description:  Enter destination_import_event_id into export_event table
--

update export_event set
  destination_import_event_id = ?,
  destination_import_event_closed = false
where
  export_event_id = ?