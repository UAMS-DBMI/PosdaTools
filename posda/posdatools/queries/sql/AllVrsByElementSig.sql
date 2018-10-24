-- Name: AllVrsByElementSig
-- Schema: posda_phi
-- Columns: ['vr', 'element_signature', 'equipment_signature', 'count']
-- Args: ['scan_id', 'tag_signature']
-- Tags: ['tag_usage']
-- Description: List of values seen in scan by ElementSignature with VR and count
-- 

select distinct vr, element_signature, equipment_signature, count(*)
from (
select
  distinct series_instance_uid, element_signature, vr,
  equipment_signature
from
  scan_event natural join series_scan
  natural join scan_element natural join element_signature
  natural join equipment_signature
where
  scan_event_id = ? and
  element_signature = ?
) as foo
group by element_signature, vr, equipment_signature
order by element_signature, vr, equipment_signature
