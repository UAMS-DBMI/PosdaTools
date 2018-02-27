-- Name: SimplePhiReportAllRelevantPrivateOnlyWithMetaQuotes
-- Schema: posda_phi_simple
-- Columns: ['element', 'vr', 'q_value', 'description', 'disp', 'num_series']
-- Args: ['scan_id']
-- Tags: ['tag_usage', 'meta_q_queries']
-- Description: Status of PHI scans
-- 

select 
  distinct '<' || element_sig_pattern || '>'  as element,
  vr, '<' || value || '>' as q_value, tag_name as description, private_disposition as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and is_private and private_disposition not in ('d', 'na', 'o', 'h')
group by element_sig_pattern, vr, value, description, disp
order by vr, element