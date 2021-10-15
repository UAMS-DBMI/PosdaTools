-- Name: FailedNiftiConversionByActivity
-- Schema: posda_files
-- Columns: ['nifti_file_from_series_id', 'series_instance_uid']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description: List of failed NiftiConversions for this activity
-- 

select
  distinct nifti_file_from_series_id, series_instance_uid
from
  nifti_file_from_series join dicom_to_nifti_conversion using (dicom_to_nifti_conversion_id)
  join activity_timepoint using (activity_timepoint_id) 
where
  activity_id = ? and nifti_file_id is null;