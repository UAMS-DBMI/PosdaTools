-- Name: GetValueForTagBySeries
-- Schema: posda_phi
-- Columns: ['series_instance_uid', 'tag', 'value']
-- Args: ['series_instance_uid', 'tag']
-- Tags: ['tag_values']
-- Description: Find Distinct value for a given tag for a particular scanned series
-- 

select
  distinct series_instance_uid, element_signature as tag, value
from
  series_scan natural join scan_element natural join seen_value natural join element_signature
where
  series_instance_uid = ? and element_signature = ?