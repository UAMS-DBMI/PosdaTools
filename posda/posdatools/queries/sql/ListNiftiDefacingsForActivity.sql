-- Name: ListNiftiDefacingsForActivity
-- Schema: posda_files
-- Columns: ['subprocess_invocation_id']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description: List file_nifti_defacings for this actiity
-- 

select
  distinct subprocess_invocation_id
from
  file_nifti_defacing
where
  from_nifti_file in (
    select file_id
    from activity_timepoint_file
    where activity_timepoint_id in (
      select activity_timepoint_id
      from activity_timepoint
      where activity_id = ?
   )
)