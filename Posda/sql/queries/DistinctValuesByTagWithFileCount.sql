-- Name: DistinctValuesByTagWithFileCount
-- Schema: posda_phi
-- Columns: ['element_signature', 'value', 'num_files']
-- Args: ['tag']
-- Tags: ['tag_usage']
-- Description: Distinct values for a tag with file count
-- 

select distinct element_signature, value, count(*) as num_files
from (
select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, value
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  element_signature = ?
order by series_instance_uid, file, value
) as foo
group by element_signature, value
