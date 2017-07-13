-- Name: SeriesEquipmentByValueSignature
-- Schema: posda_phi
-- Columns: ['series_instance_uid', 'value', 'vr', 'element_signature', 'equipment_signature']
-- Args: ['scan_id', 'value', 'tag_signature']
-- Tags: ['tag_usage']
-- Description: List of series, values, vr seen in scan with equipment signature
-- 

select
  distinct series_instance_uid, element_signature, value, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
  natural join seen_value
where
  scan_event_id = ? and
  value = ? and
  element_signature = ?
order by value, element_signature, vr
