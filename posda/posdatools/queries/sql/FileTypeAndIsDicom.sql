-- Name: FileTypeAndIsDicom
-- Schema: posda_files
-- Columns: ['file_type', 'is_dicom_file']
-- Args: ['file_id']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Get the file_type of a file, by file_id
-- 

select file_type, is_dicom_file
from file
where file_id = ?
