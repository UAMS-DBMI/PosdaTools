-- Name: GetNonDicomFilesInImportEvent
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'file_name', 'size', 'file_import_time']
-- Args: ['import_event_id']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab
-- 

select file_id, file_type, 
file_name, size, file_import_time
from file natural join file_import
where not is_dicom_file and import_event_id = ?