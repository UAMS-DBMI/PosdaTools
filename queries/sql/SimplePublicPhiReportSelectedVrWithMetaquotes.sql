-- Name: SimplePublicPhiReportSelectedVrWithMetaquotes
-- Schema: posda_phi_simple
-- Columns: ['element', 'vr', 'q_value', 'description', 'disp', 'num_series']
-- Args: ['scan_id']
-- Tags: ['tag_usage', 'meta_q_queries']
-- Description: Status of PHI scans
-- 

select 
  distinct '<' || element_sig_pattern || '>' as element, vr, '<' || value || '>' as q_value, tag_name as description, 
  ' ' as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and
  not is_private and
  vr in ('SH', 'OB', 'PN', 'DA', 'ST', 'AS', 'DT', 'LO', 'UI', 'CS', 'AE', 'LT', 'ST', 'UC', 'UN', 'UR', 'UT')
group by element, vr, q_value, tag_name, disp
order by vr, element, q_value