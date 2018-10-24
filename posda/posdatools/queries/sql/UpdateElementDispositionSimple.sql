-- Name: UpdateElementDispositionSimple
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['disp', 'id']
-- Tags: ['tag_usage', 'used_in_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

update
  element_seen
set
  private_disposition = ?
where
  element_seen_id = ?