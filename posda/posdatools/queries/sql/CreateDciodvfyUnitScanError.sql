-- Name: CreateDciodvfyUnitScanError
-- Schema: posda_phi_simple
-- Columns: []
-- Args: [' dicodvfy_scan_instance_id', 'dciodvfy_unit_scan_id', 'dciodvfy_error_id']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_unit_scan_error row

insert into dciodvfy_unit_scan_error(
  dciodvfy_scan_instance_id,
  dciodvfy_unit_scan_id,
  dciodvfy_error_id
)values (?, ?, ?)