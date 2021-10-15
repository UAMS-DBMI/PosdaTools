-- Name: AddDcm2NiftiStuff
-- Schema: posda_files
-- Columns: []
-- Args: ['nifti_file_id', 'nifti_json_file_id', 'nifti_base_file_name', 'specified_gantry_tile', 'computed_gantry_tile', 'conversion_time', 'nifti_file_from_series_id']
-- Tags: ['nifti']
-- Description: Update nifti_file_from_series table to add information from dcm2nifti
-- 

update nifti_file_from_series set
  nifti_file_id = ?, 
  nifti_json_file_id = ?,
  nifti_base_file_name = ?,
  specified_gantry_tilt = ?,
  computed_gantry_tilt = ?,
  conversion_time = ?
where
  nifti_file_from_series_id = ?
