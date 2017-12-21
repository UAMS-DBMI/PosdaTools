-- Name: LastNPhiScans
-- Schema: posda_phi_simple
-- Columns: ['id', 'start_time', 'end_time', 'duration', 'description', 'to_scan', 'scanned']
-- Args: ['n']
-- Tags: ['tag_usage', 'scan_status']
-- Description: Status of PHI scans
-- 

select
  phi_scan_instance_id as id,
  start_time,
  end_time,
  end_time - start_time as duration,
  description,
  num_series as to_scan,
  num_series_scanned as scanned
from 
  phi_scan_instance
order by id desc
  limit ?
