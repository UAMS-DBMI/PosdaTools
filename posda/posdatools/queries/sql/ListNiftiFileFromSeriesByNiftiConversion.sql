-- Name: ListNiftiFileFromSeriesByNiftiConversion
-- Schema: posda_files
-- Columns: ['nifti_file_from_series_id', 'file_id', 'nifti_json_file_id', 'dicom_file_type', 'modality', 'series_instance_uid']
-- Args: ['dicom_to_nifti_conversion_id']
-- Tags: ['nifti']
-- Description: Find Series converted to nifti for a dicom_to_nifti_conversion
-- 

select 
  nifti_file_from_series_id,
  nifti_file_id as file_id,
  nifti_json_file_id,
  dicom_file_type, modality, series_instance_uid
from
  nifti_file_from_series
where dicom_to_nifti_conversion_id = ?