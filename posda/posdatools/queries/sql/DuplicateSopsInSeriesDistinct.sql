-- Name: DuplicateSopsInSeriesDistinct
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'num_files', 'earliest', 'latest']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'dup_sops']
-- Description: List of Actual duplicate SOPs (i.e. different files, same SOP)
-- in a series
-- 

select
  distinct sop_instance_uid,
  count(distinct file_id) as num_files,
  min(import_time) as earliest,
  max(import_time) as latest
from 
  file_sop_common
  natural join file_import natural join import_event
where sop_instance_uid in (
select sop_instance_uid from (
select
  distinct sop_instance_uid, count(distinct file_id) 
from
  file_sop_common natural join file_series natural join ctp_file
where
  series_instance_uid = ?
group by sop_instance_uid
) as foo
where count > 1
)
group by sop_instance_uid
order by sop_instance_uid