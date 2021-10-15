-- Name: SetMappedToDicomFiles
-- Schema: posda_files
-- Columns: []
-- Args: ['mapped_to_dicom_files', 'nifti_file_id']
-- Tags: ['nifti']
-- Description: Create row in file_nifti table
-- 

update nifti_file_from_series set
  mapped_to_dicom_files = ?
where nifti_file_id = ?