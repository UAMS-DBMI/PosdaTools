-- Name: AllPublicSignaturesByScanId
-- Schema: posda_phi
-- Columns: ['public_signature']
-- Args: ['scan_id']
-- Tags: ['tag_usage']
-- Description: List of non-private Element Signatures seen by Scan

select distinct element_signature as public_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
where
  scan_event_id = ? 
  and not is_private
order by public_signature