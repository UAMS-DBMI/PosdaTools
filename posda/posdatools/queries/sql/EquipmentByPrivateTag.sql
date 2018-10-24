-- Name: EquipmentByPrivateTag
-- Schema: posda_phi
-- Columns: ['equipment_signature']
-- Args: ['scan_id', 'element_signature']
-- Tags: ['tag_usage']
-- Description: Which equipment signatures for which private tags
-- 

select distinct equipment_signature from (
select
  distinct element_signature, equipment_signature
from 
  equipment_signature natural join series_scan
  natural join scan_element natural join element_signature
  natural join scan_event
where scan_event_id = ? and is_private ) as foo
where element_signature = ?
order by equipment_signature;
