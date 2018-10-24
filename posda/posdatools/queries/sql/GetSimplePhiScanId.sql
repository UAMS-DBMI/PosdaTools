-- Name: GetSimplePhiScanId
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Create a new Simple PHI scan

select currval('phi_scan_instance_phi_scan_instance_id_seq') as id