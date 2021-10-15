-- Name: ListNiftiFilesNeedingDefacingInTp
-- Schema: posda_files
-- Columns: ['nifti_file_id', 'dicom_to_nifti_conversion_id', 'series_instance_uid']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description: List nifti_conversions for an actiity timepoint which haven't been queued for defacing
-- 

select
  nifti_file_id, 
  dicom_to_nifti_conversion_id,
  series_instance_uid
from
  nifti_file_from_series nffs
where
  nifti_file_id in (
    select file_id
    from file_nifti natural join activity_timepoint_file
    where activity_timepoint_id = (
       select max(activity_timepoint_id) as activity_timepoint_id
       from activity_timepoint
       where activity_id =  ?
    )
  ) and not exists (
    select from_nifti_file
    from file_nifti_defacing fnd
    where fnd.from_nifti_file = nifti_file_id
  )
  