-- Name: SimplePhiReportPrivateOnlyByScanVrScreenDeletedPT
-- Schema: posda_phi_simple
-- Columns: ['element', 'vr', 'value', 'description', 'num_series']
-- Args: ['scan_id', 'vr']
-- Tags: ['tag_usage', 'old_simple_phi']
-- Description: Status of PHI scans
-- 

select 
  distinct element_sig_pattern as element, vr, value, 
  tag_name as description, count(*) as num_series
from element_value_occurance natural join element_seen natural join value_seen
where 
  phi_scan_instance_id = ? and vr = ? and
  is_private and
  private_disposition in ('k', 'oi', 'h', 'o')
group by element_sig_pattern, vr, value, tag_name