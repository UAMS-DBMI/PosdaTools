-- Name: AddNiftiDcm2niixWarnings
-- Schema: posda_files
-- Columns: []
-- Args: ['nifti_file_from_series_id', 'warning']
-- Tags: ['nifti']
-- Description: Create row in nifti_dcm2niix_warnings table
-- 

insert into nifti_dcm2niix_warnings(
  nifti_file_from_series_id,
  warning
) values (
  ?, ?
)