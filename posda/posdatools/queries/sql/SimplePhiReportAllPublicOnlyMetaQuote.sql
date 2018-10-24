-- Name: SimplePhiReportAllPublicOnlyMetaQuote
-- Schema: posda_phi_simple
-- Columns: ['element', 'vr', 'disp', 'q_value', 'description', 'num_series']
-- Args: ['scan_id']
-- Tags: ['adding_ctp', 'for_scripting', 'phi_reports']
-- Description: Simple Phi Report with Meta Quotes

select 
  distinct '<' || element_sig_pattern || '>'  as element, length(value) as val_length,
  vr, '<' || value || '>' as q_value, tag_name as description, 'k' as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and not is_private
group by element_sig_pattern, vr, value, val_length, description
order by vr, element, val_length