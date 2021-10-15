-- Name: ListAllConvertedNiftiFilesForActivity
-- Schema: posda_files
-- Columns: ['nifti_file_id']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description: List nifti_conversions for an actiity timepoint
-- 

select 
  nifti_file_id
from
  nifti_file_from_series natural join dicom_to_nifti_conversion
where 
  subprocess_invocation_id in (
  select
    distinct subprocess_invocation_id
  from
    dicom_to_nifti_conversion natural join nifti_file_from_series
  where
    activity_timepoint_id in (select activity_timepoint_id from activity_timepoint where activity_id = ?)
  group by dicom_to_nifti_conversion_id, subprocess_invocation_id order by subprocess_invocation_id
)
and nifti_file_id is not null