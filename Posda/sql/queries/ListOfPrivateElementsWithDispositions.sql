-- Name: ListOfPrivateElementsWithDispositions
-- Schema: posda_phi
-- Columns: ['element_signature', 'vr', 'disposition', 'element_signature_id', 'name_chain']
-- Args: []
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Get Disposition of element by sig and VR

select
  element_signature, vr , private_disposition as disposition, element_signature_id, name_chain
from
  element_signature
where
  is_private
order by element_signature
