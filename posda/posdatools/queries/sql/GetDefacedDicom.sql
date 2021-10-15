-- Name: GetDefacedDicom
-- Schema: posda_files
-- Columns: ['undefaced_nifti_file', 'defaced_nifti_file', 'original_dicom_series_instance_uid', 'defaced_dicom_series_instance_uid', 'number_of_files_text', 'import_event_comment', 'difference_nifti_file']
-- Args: ['defaced_nifti_file_id']
-- Tags: ['nifti']
-- Description: Get a report on defaced nifti files
-- 

select distinct 
  undefaced_nifti_file, defaced_nifti_file,
  original_dicom_series_instance_uid, defaced_dicom_series_instance_uid,
  number_of_files,
  import_event_comment,
  difference_nifti_file
from 
  defaced_dicom_series
where
  defaced_nifti_file = ?