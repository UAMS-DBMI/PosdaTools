-- Name: GetValueForTagAllScans
-- Schema: posda_phi
-- Columns: ['tag', 'value']
-- Args: ['tag']
-- Tags: ['tag_values']
-- Description: Find Values for a given tag for all scanned series in a phi scan instance
-- 

select
  distinct element_signature as tag, value
from
  scan_element natural join series_scan natural join
  seen_value natural join element_signature
where element_signature = ?
order by value