-- Name: UpdPosdaPhiSimpleEleName
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['name', 'is_private', 'element_signature', 'vr']
-- Tags: ['NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Update name_chain in element_seen

update
  element_seen
set
  tag_name = ?,
  is_private = ?
where
  element_sig_pattern = ? and
  vr = ?

