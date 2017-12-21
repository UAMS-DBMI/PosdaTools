-- Name: MarkPrivateTags
-- Schema: posda_phi_simple
-- Columns: ['id', 'element_sig_pattern', 'vr', 'tag_name', 'disp']
-- Args: []
-- Tags: ['tag_usage', 'simple_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

update element_seen set
  is_private = true
where
  is_private is null and 
  element_sig_pattern like '%"%'
