-- Name: GetNonDicomFilesInTimepoint
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'file_name', 'file_size', 'file_import_time']
-- Args: ['activity_timepoint_id']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab
-- 

select file_id, file_type, 
file_name, size, file_import_time
from file natural join file_import natural join activity_timepoint_file
where not is_dicom_file and activity_timepoint_id = ?