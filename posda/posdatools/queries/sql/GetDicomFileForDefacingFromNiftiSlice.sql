-- Name: GetDicomFileForDefacingFromNiftiSlice
-- Schema: posda_files
-- Columns: ['dicom_file_id']
-- Args: ['nifti_file_id', 'nifti_slice_number']
-- Tags: ['nifti']
-- Description: Get row in file_nifti table from file_id
-- 

select
  dicom_file_id, nifti_file_id, nifti_slice_number 
from dicom_slice_nifti_slice 
where nifti_file_id = ? and nifti_slice_number = ?