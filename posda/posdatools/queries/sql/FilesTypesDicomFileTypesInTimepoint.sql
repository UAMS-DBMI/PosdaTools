-- Name: FilesTypesDicomFileTypesInTimepoint
-- Schema: posda_files
-- Columns: ['file_id', 'file_path', 'file_type', 'dicom_file_type']
-- Args: ['activity_timepoint_id']
-- Tags: []
-- Description: Get file_id, file_type and dicom_file_type for files in timepoint
-- 

select
  file_id, root_path || '/' || rel_path as file_path, file_type, dicom_file_type
from
  file natural left join dicom_file
  natural join file_location natural join file_storage_root
where file_id in (
  select
    file_id
  from
    activity_timepoint_file
  where
    activity_timepoint_id = ?
)
