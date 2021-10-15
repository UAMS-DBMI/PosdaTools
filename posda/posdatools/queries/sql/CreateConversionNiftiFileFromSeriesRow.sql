-- Name: CreateConversionNiftiFileFromSeriesRow
-- Schema: posda_files
-- Columns: []
-- Args: ['dicom_to_nifti_conversion_id', 'series_instance_uid', 'num_files_in_series', 'num_files_selected_from_series', 'modality', 'dicom_file_type', 'iop', 'first_ipp', 'last_ipp']
-- Tags: ['nifti']
-- Description: Create row in nifti_file_from_series table for which nifti conversion was done
-- 

insert into nifti_file_from_series(
  dicom_to_nifti_conversion_id, series_instance_uid, num_files_in_series, 
  num_files_selected_from_series, modality, dicom_file_type,
  iop, first_ipp, last_ipp, dcm2nii_invoked
) values (
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  true
)
returning nifti_file_from_series_id