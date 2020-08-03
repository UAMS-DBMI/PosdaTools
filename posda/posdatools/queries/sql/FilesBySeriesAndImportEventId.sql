-- Name: FilesBySeriesAndImportEventId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['series_instance_uid', 'import_event_id']
-- Tags: []
-- Description: List of Files in a Series and ImportEvent
--

select distinct file_id
from file_series natural join file_import
where series_instance_uid = ? and import_event_id = ?