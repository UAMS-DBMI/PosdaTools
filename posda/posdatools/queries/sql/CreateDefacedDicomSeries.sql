-- Name: CreateDefacedDicomSeries
-- Schema: posda_files
-- Columns: []
-- Args: ['subprocess_invocation_id', 'undefaced_nifti_file', 'defaced_nifti_file', 'original_dicom_series_instance_uid', 'defaced_dicom_series_instance_uid', 'number_of_files', 'import_event_comment']
-- Tags: ['nifti']
-- Description: Create a row in defaced_dicom_series
-- 

insert into defaced_dicom_series (
  subprocess_invocation_id,
  undefaced_nifti_file,
  defaced_nifti_file,
  original_dicom_series_instance_uid,
  defaced_dicom_series_instance_uid,
  number_of_files,
  import_event_comment
) values (
  ?, ?, ?, ?,
  ?, ?, ?
)