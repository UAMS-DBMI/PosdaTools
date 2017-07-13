-- Name: CreateSimplePhiScanRow
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['description', 'num_series', 'file_query']
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Create a new Simple PHI scan

insert into phi_scan_instance(
description, num_series, start_time, num_series_scanned,file_query
)values(?, ?,now(), 0,?)
returning phi_scan_instance_id