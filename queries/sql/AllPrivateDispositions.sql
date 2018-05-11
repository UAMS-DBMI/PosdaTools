-- Name: AllPrivateDispositions
-- Schema: posda_phi_simple
-- Columns: ['element_sig_pattern', 'tag_name', 'vr', 'element_seen_id', 'private_disposition']
-- Args: []
-- Tags: ['tag_usage', 'used_in_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

select 
  distinct element_sig_pattern, vr, tag_name, element_seen_id, private_disposition
from 
  element_seen
where
  is_private
order by element_sig_pattern,vr