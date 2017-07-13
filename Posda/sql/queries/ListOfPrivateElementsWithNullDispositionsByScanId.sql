-- Name: ListOfPrivateElementsWithNullDispositionsByScanId
-- Schema: posda_phi
-- Columns: ['element_signature', 'vr', 'disposition', 'element_signature_id', 'name_chain']
-- Args: ['scan_id']
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Get Disposition of element by sig and VR

select
  distinct element_signature, vr , private_disposition as disposition,
  element_signature_id, name_chain
from
  element_signature natural join scan_element natural join series_scan
where
  is_private and scan_event_id = ? and private_disposition is null
order by element_signature
