-- Name: ElementScanIdByScanValueTag
-- Schema: posda_phi
-- Columns: ['scan_element_id']
-- Args: ['scan_id', 'value', 'tag']
-- Tags: ['tag_usage']
-- Description: Find out where specific value, tag combinations occur in a scan
-- 

select 
  distinct scan_element_id
from
  scan_element natural join element_signature
  natural join series_scan natural join seen_value
  natural join scan_event
where
  scan_event_id = ? and
  value = ? and
  element_signature = ?
