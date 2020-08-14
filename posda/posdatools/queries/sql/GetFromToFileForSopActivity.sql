-- Name: GetFromToFileForSopActivity
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['sop_instance_uid', 'activity_id']
-- Tags: ['NotInteractive']
-- Description: Gets file_id and path for SOP in latest timepoint of current activity
--

select
 file_id, root_path || '/' || rel_path as path
from
 file_location natural join file_storage_root natural join file_sop_common
 natural join activity_timepoint_file
where
  sop_instance_uid = ? and
  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )