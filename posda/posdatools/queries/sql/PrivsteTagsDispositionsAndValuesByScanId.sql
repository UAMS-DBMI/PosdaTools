-- Name: PrivsteTagsDispositionsAndValuesByScanId
-- Schema: posda_phi_simple
-- Columns: ['element_seen_id', 'element_sig_pattern', 'tag_name', 'private_disposition', 'value']
-- Args: ['phi_scan_instance_id']
-- Tags: ['tag_usage', 'simple_phi_maint', 'phi_maint']
-- Description: Private tags with no disposition with values in phi_simple

select 
  distinct element_seen_id, element_sig_pattern, tag_name, private_disposition, value
from
  element_value_occurance natural join element_seen natural join value_seen 
where
  phi_scan_instance_id = ? and element_sig_pattern like '%"%'
order by element_sig_pattern;
