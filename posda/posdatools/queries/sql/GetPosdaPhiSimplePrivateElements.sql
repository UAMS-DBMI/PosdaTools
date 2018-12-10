-- Name: GetPosdaPhiSimplePrivateElements
-- Schema: posda_phi_simple
-- Columns: ['element_seen_id', 'element_sig_pattern', 'vr', 'is_private', 'private_disposition', 'tag_name']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Get the relevant features of an element_signature in posda_phi_simple schema

select
  element_seen_id,
  element_sig_pattern,
  vr,
  is_private,
  private_disposition,
  tag_name
from element_seen
where element_sig_pattern like '%"%'

