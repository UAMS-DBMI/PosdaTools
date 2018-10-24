-- Name: DistinctDispositionsNeededSimple
-- Schema: posda_phi_simple
-- Columns: ['id', 'element_sig_pattern', 'vr', 'tag_name']
-- Args: []
-- Tags: ['tag_usage', 'simple_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

select 
  distinct 
  element_seen_id as id, 
  element_sig_pattern,
  vr,
  tag_name
from
  element_seen
  natural join element_value_occurance
  natural join value_seen
where
  is_private and 
  private_disposition is null
