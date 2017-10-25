-- Name: FilesWithIndicesByElementScanId
-- Schema: posda_phi
-- Columns: ['series_instance_uid', 'file', 'element_signature', 'sequence_level', 'item_number']
-- Args: ['scan_element_id']
-- Tags: ['tag_usage']
-- Description: Find out where specific value, tag combinations occur in a scan
-- 

select
  distinct series_instance_uid,
  series_scanned_file as file, 
  element_signature, sequence_level,
  item_number
from
  series_scan natural join element_signature natural join 
  scan_element natural left join sequence_index
where
  scan_element_id = ?
