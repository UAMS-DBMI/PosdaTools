-- Name: AddPhiSimpleElement
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['element_signature', 'vr', 'is_private', 'private_disposition', 'name_chain']
-- Tags: ['NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Add an element_seen row to posda_phi_simple

insert into element_seen (
  element_sig_pattern,
  vr,
  is_private,
  private_disposition,
  tag_name
) values (
  ?, ?, ?, ?, ?
)
returning element_seen_id
