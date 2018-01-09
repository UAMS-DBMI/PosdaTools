-- Name: DistinctVrByScan
-- Schema: posda_phi_simple
-- Columns: ['vr', 'num_series']
-- Args: ['scan_id']
-- Tags: ['tag_usage', 'old_simple_phi']
-- Description: Status of PHI scans
-- 

select 
  distinct vr, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? 
group by vr