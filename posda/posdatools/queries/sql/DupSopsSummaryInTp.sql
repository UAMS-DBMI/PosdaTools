-- Name: DupSopsSummaryInTp
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'num_files', 'num_occurances']
-- Args: ['activity_timepoint_id']
-- Tags: ['dup_sops']
-- Description: Find series with DupSops in TP with count of dups and occurances
-- 

select
  series_instance_uid, num_files, count(*) as num_occurances
from (
  select 
    distinct sop_instance_uid, series_instance_uid, count(distinct file_id) as num_files
  from
    file_series natural join activity_timepoint_file natural join file_sop_common
  where activity_timepoint_id = ?
  group by sop_instance_uid, series_instance_uid
) as foo
where num_files > 1
group by series_instance_uid, num_files
order by num_files desc
