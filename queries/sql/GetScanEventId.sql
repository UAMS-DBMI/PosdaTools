-- Name: GetScanEventId
-- Schema: posda_phi
-- Columns: []
-- Args: []
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: List of values seen in scan by VR (with count of elements)
-- 

select currval('series_scan_series_scan_id_seq') as id