-- Name: FinalizeSimpleSeriesScan
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['num_files', 'id']
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Finalize Series Scan

update series_scan_instance set
  num_files = ?,
  end_time = now()
where
  series_scan_instance_id = ?