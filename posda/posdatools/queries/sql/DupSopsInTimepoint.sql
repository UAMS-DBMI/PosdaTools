-- Name: DupSopsInTimepoint
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'num_files']
-- Args: ['activity_id']
-- Tags: ['dup_sops']
-- Description:  Find any dup sops in latest timepoint for activity
-- 

select
  sop_instance_uid, num_files
from (
  select distinct sop_instance_uid, count(distinct file_id) as num_files
  from file_sop_common natural join activity_timepoint_file
  where activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint where activity_id = ?
  )
  group by sop_instance_uid
) as foo
where num_files > 1