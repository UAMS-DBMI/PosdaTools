-- Name: ListOfPrivateElementsFromDD
-- Schema: posda_private_tag
-- Columns: ['tag', 'vr', 'vm', 'name']
-- Args: []
-- Tags: ['ElementDisposition']
-- Description: Get List of Private Tags from DD

select
  pt_signature as tag,
  pt_consensus_vr as vr,
  pt_consensus_vm as vm,
  pt_consensus_name as name
from
  pt