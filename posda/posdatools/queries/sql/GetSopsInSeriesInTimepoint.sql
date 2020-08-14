-- Name: GetSopsInSeriesInTimepoint
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['series_instance_uid', 'activity_id']
-- Tags: ['sops_in_series']
-- Description: Get SOP instance uid each file by series in latest timepoint for activit y
--

select
  sop_instance_uid
from 
  file_series natural join file_sop_common
  natural join activity_timepoint_file
where series_instance_uid = ? and
  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )