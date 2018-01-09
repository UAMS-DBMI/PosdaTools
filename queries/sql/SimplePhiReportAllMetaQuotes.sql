-- Name: SimplePhiReportAllMetaQuotes
-- Schema: posda_phi_simple
-- Columns: ['element', 'vr', 'q_value', 'description', 'num_series']
-- Args: ['scan_id']
-- Tags: ['tag_usage', 'meta_q_queries']
-- Description: Status of PHI scans
-- 

select 
  distinct '<' || element_sig_pattern || '>' as element, vr, 
  '<' || value || '>' as q_value, tag_name as description, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ?
group by element_sig_pattern, vr, value, description
order by vr, element