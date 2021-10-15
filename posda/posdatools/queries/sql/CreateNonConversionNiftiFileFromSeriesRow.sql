-- Name: CreateNonConversionNiftiFileFromSeriesRow
-- Schema: posda_files
-- Columns: []
-- Args: ['dicom_to_nifti_conversion_id', 'series_instance_uid', 'num_files_in_series']
-- Tags: ['nifti']
-- Description: Create row in nifti_file_from_series table for which no nifti conversion was done (no files selected)
-- 

insert into nifti_file_from_series(
  dicom_to_nifti_conversion_id,
  series_instance_uid,
  num_files_in_series,
  num_files_selected_from_series,
  dcm2nii_invoked
) values (
   ?, ?, ?, 0, false
)
returning nifti_file_from_series_id