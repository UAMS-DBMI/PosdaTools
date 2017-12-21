-- Name: SeriesForPhi
-- Schema: posda_phi_simple
-- Columns: ['series_instance_uid']
-- Args: ['scan_id', 'element_sig_pattern', 'value']
-- Tags: ['tag_usage', 'old_simple_phi', 'phi_simple', 'simple_phi']
-- Description: Status of PHI scans
-- 

select 
  series_instance_uid 
from 
  series_scan_instance
where series_scan_instance_id in (
  select series_scan_instance_id from (
    select * from element_value_occurance 
    where
      phi_scan_instance_id = ? and
      element_seen_id in (
        select element_seen_id from element_seen
        where element_sig_pattern = ?
      ) and 
      value_seen_id in (
        select value_seen_id from value_seen
        where value = ?
      )
  ) as foo
)