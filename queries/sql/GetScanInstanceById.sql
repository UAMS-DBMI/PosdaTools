-- Name: GetScanInstanceById
-- Schema: posda_phi_simple
-- Columns: ['phi_scan_instance_id', 'start_time', 'end_time', 'description', 'num_series', 'num_series_scanned', 'file_query']
-- Args: ['phi_scan_instance_id']
-- Tags: ['tag_usage', 'scan_status']
-- Description: Status of PHI scans
-- 

select
  phi_scan_instance_id,
  start_time,
  end_time,
  description,
  num_series,
  num_series_scanned,
  file_query
from 
  phi_scan_instance
where phi_scan_instance_id = ?
