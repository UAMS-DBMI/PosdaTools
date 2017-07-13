-- Name: GetScanEventEventId
-- Schema: posda_phi
-- Columns: ['num_series_scanned', 'id']
-- Args: []
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Get current value of scan_event_id

select currval('scan_event_scan_event_id_seq') as id
