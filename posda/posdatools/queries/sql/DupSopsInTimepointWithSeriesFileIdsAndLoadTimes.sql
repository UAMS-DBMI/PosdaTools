-- Name: DupSopsInTimepointWithSeriesFileIdsAndLoadTimes
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'sop_instance_uid', 'file_id', 'import_time', 'import_type', 'import_comment']
-- Args: ['activity_id']
-- Tags: ['dup_sops']
-- Description:  Find any dup sops in latest timepoint for activity
-- 

select
  series_instance_uid, sop_instance_uid, file_id, 
  coalesce(file_import_time, import_time) as import_time, import_type, import_comment
from (
  select distinct series_instance_uid, sop_instance_uid, count(distinct file_id) as num_files
  from file_series natural join file_sop_common natural join activity_timepoint_file
  where activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint where activity_id = ?
  )
  group by series_instance_uid, sop_instance_uid
) as foo
natural join file_sop_common
natural join file_import
natural join import_event
where num_files > 1
order by series_instance_uid, sop_instance_uid, import_time desc