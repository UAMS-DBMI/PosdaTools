-- Name: GetDupSopsAndFileIdsBySeriesTp
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'file_id']
-- Args: ['activity_timepoint_id_1', 'series_instance_uid', 'activity_timepoint_id']
-- Tags: ['dup_sops']
-- Description: Gets DupSops with ordered file_ids in series, TP
-- 

select
  distinct sop_instance_uid, file_id
from
  file_sop_common natural join activity_timepoint_file
where
  activity_timepoint_id = ?
  and sop_instance_uid in (
  select sop_instance_uid from (
    select 
      distinct sop_instance_uid, count(distinct file_id) as num_files
    from
      file_series natural join activity_timepoint_file natural join file_sop_common
    where series_instance_uid = ? and activity_timepoint_id = ?
    group by sop_instance_uid
  ) as foo
  where num_files > 1
)
order by sop_instance_uid, file_id