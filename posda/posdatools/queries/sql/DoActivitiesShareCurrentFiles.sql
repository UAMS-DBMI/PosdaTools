-- Name: DoActivitiesShareCurrentFiles
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['act_id_one', 'act_id_two']
-- Tags: ['activity_crosstalk']
-- Description: Get list of files shared in latest activity timepoints in two activities
--

select distinct file_id from activity_timepoint_file where activity_timepoint_id =(
select max(activity_timepoint_id) as activity_timepoint_id from activity_timepoint where activity_id = ?)
intersect
select distinct file_id from activity_timepoint_file where activity_timepoint_id =(
select max(activity_timepoint_id) as activity_timepoint_id from activity_timepoint where activity_id = ?);