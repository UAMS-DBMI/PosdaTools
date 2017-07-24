-- Name: GetImportEventId
-- Schema: posda_files
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'used_in_file_import_into_posda']
-- Description: Get posda file id of created import_event row

select  currval('import_event_import_event_id_seq') as id
