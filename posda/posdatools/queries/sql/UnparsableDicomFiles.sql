-- Name: UnparsableDicomFiles
-- Schema: posda_files
-- Columns: ['file_id', 'digest', 'size', 'is_dicom_file', 'file_type', 'processing_priority', 'ready_to_process']
-- Args: []
-- Tags: []
-- Description: Find all of the files which UNIX thinks are DICOM, but which fail to parse as DICOM
-- 

select * from file where file_type like 'DICOM%'