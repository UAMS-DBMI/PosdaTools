-- Name: SimplePhiReportAllPrivateOnly
-- Schema: posda_phi_simple
-- Columns: ['element', 'vr', 'disp', 'value', 'description', 'num_series']
-- Args: ['scan_id']
-- Tags: ['tag_usage']
-- Description: Status of PHI scans
-- 

select 
  distinct '<' || element_sig_pattern || '>'  as element, length(value) as val_length,
  vr, value, tag_name as description, private_disposition as disp, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and is_private
group by element_sig_pattern, vr, value, val_length, description, disp
order by vr, element, val_length