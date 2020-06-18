-- Name: DoActivitiesShareCurrentSops
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['act_id_one', 'act_id_two']
-- Tags: ['activity_crosstalk']
-- Description: Get list of files shared in latest activity timepoints in two activities
--

select distinct sop_instance_uid from activity_timepoint_file natural join file_sop_common
where activity_timepoint_id =(
  select max(activity_timepoint_id) as activity_timepoint_id from activity_timepoint where activity_id = ?
)
intersect
select distinct sop_instance_uid from activity_timepoint_file natural join file_sop_common
where activity_timepoint_id =(
  select max(activity_timepoint_id) as activity_timepoint_id from activity_timepoint where activity_id = ?
)