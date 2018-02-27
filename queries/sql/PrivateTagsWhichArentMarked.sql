-- Name: PrivateTagsWhichArentMarked
-- Schema: posda_phi_simple
-- Columns: ['id', 'element_sig_pattern', 'vr', 'tag_name', 'disp']
-- Args: []
-- Tags: ['tag_usage', 'simple_phi', 'simple_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

select 
  distinct 
  element_seen_id as id, 
  element_sig_pattern,
  vr,
  tag_name,
  private_disposition as disp
from
  element_seen
where
  is_private is null and 
  element_sig_pattern like '%"%'
