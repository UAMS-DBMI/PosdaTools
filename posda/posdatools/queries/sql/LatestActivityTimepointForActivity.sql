-- Name: LatestActivityTimepointForActivity
-- Schema: posda_queries
-- Columns: ['activity_timepoint_id']
-- Args: ['activity_id']
-- Tags: ['activity_timepoints']
-- Description: Get Latest (max) (current) activity_timepoint_id for an activiy
--

select
 max(activity_timepoint_id) as activity_timepoint_id
from
  activity_timepoint
where
  activity_id = ?
