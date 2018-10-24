-- Name: SetDciodvfyScanInstanceNumScanned
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['scanned_so_far', 'dciodvfy_scan_instance_id']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_scan_instance row

update dciodvfy_scan_instance set
  scanned_so_far = ?
where
  dciodvfy_scan_instance_id = ?