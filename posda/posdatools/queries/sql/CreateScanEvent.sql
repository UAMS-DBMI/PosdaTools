-- Name: CreateScanEvent
-- Schema: posda_phi
-- Columns: []
-- Args: ['description', 'num_series_to_scan']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Create Scan Element

insert into scan_event(
  scan_started, scan_status, scan_description,
  num_series_to_scan, num_series_scanned
) values (
  now(), 'In Process', ?,
  ?, 0
)

