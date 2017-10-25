-- Name: IncrementSimpleSeriesScanned
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['id']
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Increment series scanned

update phi_scan_instance set
  num_series_scanned = num_series_scanned + 1
where
  phi_scan_instance_id = ?