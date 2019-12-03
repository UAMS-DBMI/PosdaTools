-- Name: GetPrivateIdTagNameVrSignatureByLikeSignature
-- Schema: posda_phi_simple
-- Columns: ['id', 'element_sig_pattern', 'vr', 'tag_name', 'disp']
-- Args: ['element_sig_pattern_like']
-- Tags: ['DispositionReport', 'NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Get Private Tags for making keep

select
  element_seen_id as id, element_sig_pattern,vr,tag_name,private_disposition as disp
from
  element_seen
where
  element_sig_pattern like ?