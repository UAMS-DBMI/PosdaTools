-- Name: FilesByScanValueLikeTag
-- Schema: posda_phi
-- Columns: ['series_instance_uid', 'file', 'element_signature', 'value', 'sequence_level', 'item_number']
-- Args: ['scan_id', 'value', 'tag']
-- Tags: ['tag_usage', 'phi_review']
-- Description: Find out where specific value, tag combinations occur in a scan
-- 

select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, value, sequence_level,
  item_number
from
  scan_event natural join series_scan natural join seen_value
  natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_event_id = ? and value like ? and element_signature = ?
order by series_instance_uid, file
