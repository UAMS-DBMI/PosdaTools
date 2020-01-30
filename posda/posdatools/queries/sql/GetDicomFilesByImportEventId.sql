-- Name: GetDicomFilesByImportEventId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['import_event_id']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Same as GetDicomFilesByImportName but for EventID
-- 

select
distinct file_id
from import_event
natural join file_import
natural join dicom_file
where
import_event_id = ?
