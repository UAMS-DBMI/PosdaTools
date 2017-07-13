-- Name: PhiScanStatus
-- Schema: posda_phi
-- Columns: ['id', 'description', 'start_time', 'end_time', 'duration', 'status', 'to_scan', 'scanned']
-- Args: []
-- Tags: ['tag_usage', 'phi_review']
-- Description: Status of PHI scans
-- 

select
  scan_event_id as id,
  scan_started as start_time,
  scan_ended as end_time,
  scan_ended - scan_started as duration,
  scan_status as status,
  scan_description as description,
  num_series_to_scan as to_scan,
  num_series_scanned as scanned
from 
  scan_event
order by id
