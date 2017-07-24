-- Name: CreateSimpleSeriesScanInstance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['scan_instance_id', 'series_instance_uid']
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Create a new Simple PHI scan

insert into series_scan_instance(
scan_instance_id, series_instance_uid, start_time
)values(?, ?, now())
returning series_scan_instance_id