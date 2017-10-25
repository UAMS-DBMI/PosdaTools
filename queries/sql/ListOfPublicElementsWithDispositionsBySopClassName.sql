-- Name: ListOfPublicElementsWithDispositionsBySopClassName
-- Schema: posda_phi
-- Columns: ['element_signature', 'vr', 'disposition', 'name_chain']
-- Args: ['sop_class_uid', 'name']
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Get Public Disposition of element by sig and VR for SOP Class and name

select
  element_signature, vr , disposition, name_chain
from
  element_signature natural join public_disposition
where
  sop_class_uid = ? and name = ?
order by element_signature
