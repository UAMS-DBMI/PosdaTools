-- Name: LatestTimepoint
-- Schema: posda_files
-- Columns: ['activity_timepoint_id']
-- Args: ['activity_id']
-- Tags: []
-- Description: Get the latest timepoint for an activity
-- 

select
  max(activity_timepoint_id) as activity_timepoint_id 
from
  activity_timepoint_file natural join activity_timepoint
where
  activity_id = ?
