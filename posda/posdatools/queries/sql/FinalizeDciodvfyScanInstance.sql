-- Name: FinalizeDciodvfyScanInstance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['dciodvfy_scan_instance_id']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_scan_instance row

update dciodvfy_scan_instance set
  end_time = now()
where
  dciodvfy_scan_instance_id = ?