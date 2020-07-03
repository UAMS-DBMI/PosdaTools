-- Name: FilesVisibilityByActivity
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['activity_id']
-- Tags: ['activity_timepoints']
-- Description: Get files with visibility in latest timepoint of activity
--

select
  distinct file_id, visibility
from
 activity_timepoint_file natural left join ctp_file
where
  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )