-- Name: SimplePhiReportSelectedVR
-- Schema: posda_phi_simple
-- Columns: ['element', 'vr', 'value', 'num_series']
-- Args: ['scan_id']
-- Tags: ['tag_usage', 'simple_phi']
-- Description: Status of PHI scans
-- 

select 
  distinct element_sig_pattern as element, vr, value, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and
  vr in ('SH', 'OB', 'PN', 'DA', 'ST', 'AS', 'DT', 'LO', 'UI', 'CS', 'AE', 'LT', 'ST', 'UC', 'UN', 'UR', 'UT')
group by element_sig_pattern, vr, value;