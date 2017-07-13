-- Name: AddPhiElement
-- Schema: posda_phi
-- Columns: []
-- Args: ['element_signature', 'vr', 'is_private', 'private_disposition', 'name_chain']
-- Tags: ['NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Add an element_signature row to posda_phi

insert into element_signature (
  element_signature,
  vr,
  is_private,
  private_disposition,
  name_chain
) values (
  ?, ?, ?, ?, ?
)
returning element_signature_id
