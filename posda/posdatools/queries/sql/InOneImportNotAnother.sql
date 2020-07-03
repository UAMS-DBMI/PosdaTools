-- Name: InOneImportNotAnother
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['from_import_event', 'to_import_event']
-- Tags: ['activity_timepoints']
-- Description:  Get files in timepoint
--

select file_id from file_import where import_event_id = ?
except
select file_id from file_import where import_event_id = ?