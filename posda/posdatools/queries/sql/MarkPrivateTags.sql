-- Name: MarkPrivateTags
-- Schema: posda_phi_simple
-- Columns: []
-- Args: []
-- Tags: ['tag_usage', 'simple_phi', 'simple_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple


update element_seen set
  is_private = true
where
  is_private is null and 
  element_sig_pattern like '%"%'
