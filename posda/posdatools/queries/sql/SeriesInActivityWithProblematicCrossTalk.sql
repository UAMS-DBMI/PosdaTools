-- Name: SeriesInActivityWithProblematicCrossTalk
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'series_instance_uid', 'activity_id']
-- Args: ['activity_id']
-- Tags: []
-- Description: Get a list of series_instance_uid, sop_instance_uid, activity_id
-- for all occurances of series in the latest activity_timepoint of an activity
--

select distinct series_instance_uid, sop_instance_uid, activity_id
from file_sop_common natural join activity_timepoint that_act_tp natural join
  activity_timepoint_file natural join file_series
where series_instance_uid in (
  select 
    distinct series_instance_uid
  from file_series natural join activity_timepoint_file this_act_tp
  where activity_timepoint_id in (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint this_act_tp where activity_id = ?
  )
)