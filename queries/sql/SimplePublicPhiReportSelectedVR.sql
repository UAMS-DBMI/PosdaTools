-- Name: SimplePublicPhiReportSelectedVR
-- Schema: posda_phi_simple
-- Columns: ['element', 'vr', 'value', 'tag_name', 'num_series']
-- Args: ['scan_id']
-- Tags: ['tag_usage', 'old_simple_phi']
-- Description: Status of PHI scans
-- 

select 
  distinct element_sig_pattern as element, vr, value, tag_name, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and
  not is_private and
  vr in ('SH', 'OB', 'PN', 'DA', 'ST', 'AS', 'DT', 'LO', 'UI', 'CS', 'AE', 'LT', 'ST', 'UC', 'UN', 'UR', 'UT')
group by element_sig_pattern, vr, value, tag_name
order by vr, element_sig_pattern, value