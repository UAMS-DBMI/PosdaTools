-- Name: PhiScanStatusInProcess
-- Schema: posda_phi
-- Columns: ['id', 'description', 'start_time', 'end_time', 'duration', 'status', 'to_scan', 'scanned', 'percentage', 'projected_completion']
-- Args: []
-- Tags: ['tag_usage', 'obsolete']
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
  num_series_scanned as scanned,
  (((now() - scan_started) / num_series_scanned) * (num_series_to_scan -
  num_series_scanned)) + now() as projected_completion,
  (cast(num_series_scanned as float) / 
    cast(num_series_to_scan as float)) * 100.0 as percentage
from
  scan_event
where
   num_series_to_scan > num_series_scanned
   and num_series_scanned > 0
order by id
