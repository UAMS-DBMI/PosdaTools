-- Name: SRGetSeriesForPhiInfo
-- Schema: posda_phi_simple
-- Columns: [sr_series_scan_instance_id]
-- Args: ['tag','value','sr_phi_scan_instance_id']
-- Tags: ['Structured Report']
-- Description: Return the series this tag+value+scan_id set is found in
--

select
  sr_series_scan_instance_id
from
  sr_path_value_occurance
  natural join sr_path_seen
  natural join value_seen
where  tag = ?
 and value = ?
 and sr_phi_scan_instance_id = ?;
