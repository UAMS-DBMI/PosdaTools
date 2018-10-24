-- Name: ListOfRepeatingPrivateElementsFromDD
-- Schema: posda_private_tag
-- Columns: ['tag', 'base_grp', 'id_mask', 'ext_mask', 'ext_shift', 'vr', 'vm', 'name']
-- Args: []
-- Tags: ['ElementDisposition']
-- Description: Get List of Repeating Private Tags from DD

select
  ptrg_signature_masked as tag,
  ptrg_base_grp as base_grp,
  ptrg_grp_mask as id_mask,
  ptrg_grp_ext_mask as ext_mask,
  ptrg_grp_ext_shift as ext_shift,
  ptrg_consensus_vr as vr,
  ptrg_consensus_vm as vm,
  ptrg_consensus_name as name 
from ptrg