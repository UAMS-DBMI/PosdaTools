-- Name: AllValuesByElementSigIdAndScanId
-- Schema: posda_phi
-- Columns: ['value']
-- Args: ['element_signature_id', 'scan_id']
-- Tags: ['tag_usage']
-- Description: List of values seen in scan with specified tag
-- 

select
  distinct value
from
  seen_value natural join scan_element
where
  element_signature_id = ? and series_scan_id in (
  select
    series_scan_id 
  from 
    series_scan
  where 
    scan_event_id = ?
  )
order by value
