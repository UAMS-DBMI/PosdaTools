-- Name: ListNiftiConversionsForActivity
-- Schema: posda_files
-- Columns: ['dicom_to_nifti_conversion_id', 'subprocess_invocation_id', 'num_conversions']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description: List nifti_conversions for this actiity
-- 

select
  distinct dicom_to_nifti_conversion_id, subprocess_invocation_id,
  count(*) as num_conversions
from
  dicom_to_nifti_conversion natural join nifti_file_from_series
where
  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )
group by dicom_to_nifti_conversion_id, subprocess_invocation_id order by subprocess_invocation_id;