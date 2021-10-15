-- Name: GetIncompleteNiftiDefacings
-- Schema: posda_files
-- Columns: ['nifti_file_id', 'file_nifti_defacing_id']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description: Get file_id and nifti_file_defacing_id for files in the current timepoint
-- for which defacing hasn't finished
-- 

select
  from_nifti_file as nifti_file_id,
  file_nifti_defacing_id
from file_nifti_defacing
where from_nifti_file in (
  select file_id as from_nifti_file
  from activity_timepoint_file natural join activity_timepoint
  where activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )
) and completed_time is null
