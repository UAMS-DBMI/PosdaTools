-- Name: GetAllFilesByImportEventId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['import_event_id']
-- Tags: ['activity_timepoint']
-- Description: Get All files in an import event (not just DICOM files)
--

select
distinct file_id
from import_event
natural join file_import
where
import_event_id = ?
