-- Name: NumEquipSigsForPrivateTagSigs
-- Schema: posda_phi
-- Columns: ['element_signature', 'count']
-- Args: ['scan_id']
-- Tags: ['tag_usage']
-- Description: Number of Equipment signatures in which tags are featured
-- 

select distinct element_signature, count(*) from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private) as foo
group by element_signature
order by element_signature
