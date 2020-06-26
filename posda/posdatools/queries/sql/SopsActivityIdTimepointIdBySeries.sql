-- Name: SopsActivityIdTimepointIdBySeries
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'activity_id', 'activity_timepoint_id']
-- Args: ['series_instance_uid']
-- Tags: ['activity_timepoint']
-- Description: Get Sops, ActivityId, ActivityTimepointId
-- for all files in a series
--

select
  sop_instance_uid, activity_id, max(activity_timepoint_id) as activity_timepoint_id
from file_series natural join file_sop_common natural join activity_timepoint_file natural join activity_timepoint
where series_instance_uid = ?
group by sop_instance_uid, activity_id
order by sop_instance_uid