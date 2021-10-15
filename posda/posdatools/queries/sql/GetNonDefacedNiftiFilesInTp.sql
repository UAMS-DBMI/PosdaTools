-- Name: GetNonDefacedNiftiFilesInTp
-- Schema: posda_files
-- Columns: ['nifti_file_id']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description: Get file_id in current tp which are nifti_file which have not yet been queued for defacing
-- 

select
 fn.file_id as nifti_file_id
from file_nifti fn
where file_id in (
  select file_id from activity_timepoint_file natural join activity_timepoint
  where activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )
) and not exists(
  select file_id
  from file_nifti_defacing fnd
  where fnd.from_nifti_file = fn.file_id
)
