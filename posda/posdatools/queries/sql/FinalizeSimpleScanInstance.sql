-- Name: FinalizeSimpleScanInstance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['id']
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Finalize PHI Scan

update phi_scan_instance set
  end_time = now()
where
  phi_scan_instance_id = ?