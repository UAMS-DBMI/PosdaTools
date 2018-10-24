-- Name: UpdPosdaPhiSimplePrivDisp
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['private_disposition', 'element_signature', 'vr']
-- Tags: ['NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Update name_chain in element_seen

update
  element_seen
set
  private_disposition = ?
where
  element_sig_pattern = ? and
  vr = ?

