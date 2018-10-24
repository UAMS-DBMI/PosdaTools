-- Name: UpdPosdaPhiEleName
-- Schema: posda_phi
-- Columns: []
-- Args: ['name', 'element_signature', 'vr']
-- Tags: ['NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Update name_chain in element signature

update
  element_signature
set
  name_chain = ?
where
  element_signature = ? and
  vr = ?

