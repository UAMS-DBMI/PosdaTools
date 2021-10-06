-- Name: ActivityTimepointAndVisibilityBySeries
-- Schema: posda_files
-- Columns: ['activity_id', 'activity_timepoint_id', 'visibility', 'num_files']
-- Args: ['series_instance_uid']
-- Tags: ['provenance_tracing']
-- Description: Find all occurances of series with count of files/visibility
-- in activities and activity timepoints
-- 

select
  distinct activity_id, activity_timepoint_id, visibility,
  count(distinct file_id) as num_files
from
  activity_timepoint_file natural join activity_timepoint natural left join ctp_file
where file_id in (
  select distinct file_id from file_series where series_instance_uid = ?
)
group by activity_id, activity_timepoint_id, visibility