-- Name: UpdateSeriesScanned
-- Schema: posda_phi
-- Columns: []
-- Args: ['num_series_scanned', 'scan_event_id']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Update Series Scanned in scan event
-- 

update scan_event
set num_series_scanned = ?
where scan_event_id = ?