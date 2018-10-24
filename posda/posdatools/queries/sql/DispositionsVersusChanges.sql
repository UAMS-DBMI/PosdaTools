-- Name: DispositionsVersusChanges
-- Schema: posda_phi_simple
-- Columns: ['element_sig_pattern', 'tag_name', 'element_seen_id', 'private_disposition', 'when_changed', 'new_disposition']
-- Args: []
-- Tags: ['tag_usage', 'used_in_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

select 
  element_sig_pattern, tag_name, element_seen_id, private_disposition, when_changed, new_disposition
from element_seen natural join element_disposition_changed 
order by element_sig_pattern, when_changed