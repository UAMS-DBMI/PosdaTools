-- Name: FinalizeDciodvfyUnitScan
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['num_errors_in_unit', 'num_warnings_in_unit', 'unit_scan_id']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_unit_scan row

update dciodvfy_unit_scan set
  num_errors_in_unit = ?,
  num_warnings_in_unit = ?,
  end_time = now()
where
  dciodvfy_unit_scan_id = ?
 