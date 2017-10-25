-- Name: GetScanElementId
-- Schema: posda_phi
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'UsedInPhiSeriesScan']
-- Description: Get current value of ScanElementId Sequence
-- 

select currval('scan_element_scan_element_id_seq') as id