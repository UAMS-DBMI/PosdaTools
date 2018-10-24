-- Name: GetPosdaPhiElementSigInfo
-- Schema: posda_phi
-- Columns: ['element_signature', 'vr', 'is_private', 'private_disposition', 'name_chain']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Get the relevant features of an element_signature in posda_phi schema

select
  element_signature,
  vr,
  is_private,
  private_disposition,
  name_chain
from element_signature

