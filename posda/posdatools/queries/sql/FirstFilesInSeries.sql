-- Name: FirstFilesInSeries
-- Schema: posda_files
-- Columns: ['path']
-- Args: ['series_instance_uid']
-- Tags: ['by_series']
-- Description: First files uploaded by series
-- 

select root_path || '/' || rel_path as path
from file_location natural join file_storage_root
where file_id in (
select file_id from 
  (
  select 
    distinct sop_instance_uid, min(file_id) as file_id
  from 
    file_series natural join ctp_file 
    natural join file_sop_common
  where 
    series_instance_uid = ?
    and visibility is null
  group by sop_instance_uid
) as foo);
