-- Name: CreateScanElement
-- Schema: posda_phi
-- Columns: []
-- Args: ['element_signature_id', 'seen_value_id', 'series_scan_id']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Create Scan Element

insert into scan_element(
  element_signature_id, seen_value_id, series_scan_id
)values(
  ?, ?, ?)
