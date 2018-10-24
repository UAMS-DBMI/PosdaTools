-- Name: GetDciodvfyScanInstanceId
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_scan_instance row

select currval('dciodvfy_scan_instance_dciodvfy_scan_instance_id_seq') as id