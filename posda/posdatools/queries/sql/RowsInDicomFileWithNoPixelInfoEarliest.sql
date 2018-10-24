-- Name: RowsInDicomFileWithNoPixelInfoEarliest
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['num_rows']
-- Tags: ['adding_pixels_to_dicom_file']
-- Description: List of files (id, path) which are dicom_files with undefined pixel info

select 
  file_id, root_path || '/' || rel_path as path
from dicom_file natural join file_location natural join file_storage_root
where has_pixel_data is null 
order by file_id limit ?