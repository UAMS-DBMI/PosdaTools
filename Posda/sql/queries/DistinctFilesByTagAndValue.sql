-- Name: DistinctFilesByTagAndValue
-- Schema: posda_phi
-- Columns: ['series_instance_uid', 'file', 'element_signature']
-- Args: ['tag', 'value']
-- Tags: ['tag_usage']
-- Description: Find out where specific value, tag combinations occur in a scan
-- 

select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  element_signature = ? and value = ?
order by series_instance_uid, file
