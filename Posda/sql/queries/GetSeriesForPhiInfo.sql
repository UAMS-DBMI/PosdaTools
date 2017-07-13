-- Name: GetSeriesForPhiInfo
-- Schema: posda_phi_simple
-- Columns: ['series_instance_uid']
-- Args: ['element', 'vr', 'value', 'scan_id']
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Get an element_seen row by element, vr (if present)

select 
  series_instance_uid
from 
  series_scan_instance 
where series_scan_instance_id in (
  select series_scan_instance_id 
  from element_value_occurance 
  where element_seen_id in (
    select 
      element_seen_id 
    from element_seen 
    where element_sig_pattern = ? and vr = ?
  )
  and value_seen_id in (
    select value_seen_id 
    from value_seen
    where value = ?
  )
  and phi_scan_instance_id = ?
)