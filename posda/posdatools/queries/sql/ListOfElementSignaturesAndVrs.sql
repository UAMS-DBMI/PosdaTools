-- Name: ListOfElementSignaturesAndVrs
-- Schema: posda_phi
-- Columns: ['element_signature', 'vr', 'name_chain', 'count']
-- Args: []
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Get Disposition of element by sig and VR

select
  distinct element_signature, vr, name_chain, count(*)
from
  element_signature
group by element_signature, vr, name_chain
