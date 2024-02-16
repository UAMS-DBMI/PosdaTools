-- Name: SimplePhiReportAllMetaQuotes
-- Schema: posda_phi_simple
-- Columns: ['element', 'vr', 'q_value', 'description', 'disposition', 'num_series']
-- Args: ['scan_id']
-- Tags: ['adding_ctp', 'for_scripting', 'phi_reports']
-- Description: Simple Phi Report with Meta Quotes

select 
  distinct '<' || element_sig_pattern || '>' as element, vr, 
  '<' || value || '>' as q_value, tag_name as description, 
  private_disposition as disposition, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ?
group by element_sig_pattern, vr, value, description, disposition
order by vr, element, q_value
