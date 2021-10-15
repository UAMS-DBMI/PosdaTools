-- Name: GetDcm2NiiWarningsBySeries
-- Schema: posda_files
-- Columns: ['warning']
-- Args: ['series_instance_uid']
-- Tags: ['Nifti']
-- Description: Get dcm2niix warnings by Series Instance UID
-- 

select
  warning
from nifti_dcm2niix_warnings
where
  nifti_file_from_series_id = (
    select nifti_file_from_series_id
    from nifti_file_from_series
    where series_instance_uid = ?
  )