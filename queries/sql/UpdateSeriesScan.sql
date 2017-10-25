-- Name: UpdateSeriesScan
-- Schema: posda_phi
-- Columns: []
-- Args: ['series_scan_status', 'series_scan_id']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Update Series Scan to set status
-- 

update series_scan
  set series_scan_status = ?
where series_scan_id = ?