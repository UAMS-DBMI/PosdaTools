-- Name: AddDiffNifti
-- Schema: posda_files
-- Columns: []
-- Args: ['difference_nifti_file', 'import_event_comment']
-- Tags: ['nifti']
-- Description: Create row in file_nifti table
-- 

update defaced_dicom_series set
  difference_nifti_file = ?
where import_event_comment = ?