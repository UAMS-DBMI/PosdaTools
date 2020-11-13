-- Name: GetNonDicomFileRow
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['file_id']
-- Tags: ['non_dicom_extensions']
-- Description: See if non_dicom_file row exists
-- 

select file_id from non_dicom_file where file_id = ?