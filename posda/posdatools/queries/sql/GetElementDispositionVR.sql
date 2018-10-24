-- Name: GetElementDispositionVR
-- Schema: posda_phi
-- Columns: ['element_signature_id', 'element_signature', 'vr', 'disposition', 'name_chain']
-- Args: ['element_signature', 'vr']
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Get Disposition of element by sig and VR

select
  element_signature_id, element_signature, vr, private_disposition as disposition, name_chain
from
  element_signature
where
  element_signature = ? and vr = ?
