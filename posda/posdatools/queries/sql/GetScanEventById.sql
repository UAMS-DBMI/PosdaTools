-- Name: GetScanEventById
-- Schema: posda_phi
-- Columns: ['scan_event_id', 'scan_started', 'scan_ended', 'scan_status', 'scan_description', 'num_series_to_scan', 'num_series_scanned']
-- Args: ['scan_id']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: List of values seen in scan by VR (with count of elements)
-- 

select * from scan_event where scan_event_id = ?
