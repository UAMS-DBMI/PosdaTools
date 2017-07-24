-- Name: GetValuesByEleVr
-- Schema: posda_phi
-- Columns: ['value']
-- Args: ['element_signature', 'vr']
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Get All  values in posda_phi by element, vr

select
  distinct value
from
  element_signature
  join scan_element using(element_signature_id)
  join seen_value using (seen_value_id)
where
  element_signature = ? and vr = ?
