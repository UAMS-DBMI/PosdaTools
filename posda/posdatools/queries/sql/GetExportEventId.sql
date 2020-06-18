-- Name: GetExportEventId
-- Schema: posda_files
-- Columns: ['export_event_id']
-- Args: []
-- Tags: ['export_event']
-- Description:  get the export_event_id of a newly created export_event
--

select currval('export_event_export_event_id_seq') as export_event_id;