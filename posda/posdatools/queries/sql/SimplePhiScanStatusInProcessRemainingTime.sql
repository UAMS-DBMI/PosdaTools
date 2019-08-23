-- Name: SimplePhiScanStatusInProcessRemainingTime
-- Schema: posda_phi_simple
-- Columns: ['id', 'start_time', 'duration', 'description', 'to_scan', 'scanned', 'remaining_time', 'percentage', 'file_query']
-- Args: []
-- Tags: ['tag_usage', 'simple_phi', 'phi_status', 'scan_status']
-- Description:  Status of PHI scans
--

select
  phi_scan_instance_id as id,
  start_time,
  now() - start_time as duration,
  description,
  num_series as to_scan,
  num_series_scanned as scanned,
  (((now() - start_time) / num_series_scanned) * (num_series -
  num_series_scanned)) as remaining_time,
  (cast(num_series_scanned as float) / 
    cast(num_series as float)) * 100.0 as percentage,
  file_query
from
  phi_scan_instance
where
   num_series > num_series_scanned
   and num_series_scanned > 0
order by id
