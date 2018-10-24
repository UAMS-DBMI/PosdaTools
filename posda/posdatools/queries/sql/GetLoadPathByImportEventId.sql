-- Name: GetLoadPathByImportEventId
-- Schema: posda_files
-- Columns: ['file_id', 'rel_path']
-- Args: ['import_event_id']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select file_id, rel_path from file_import where import_event_id = ?