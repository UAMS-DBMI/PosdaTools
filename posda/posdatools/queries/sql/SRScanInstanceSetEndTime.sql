-- Name: SRScanInstanceSetEndTime
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['sr_phi_scan_instance_id']
-- Tags: ['Structured Report']
-- Description: Sets the end time for an SR scan instance
--

update sr_phi_scan_instance set end_time = now() where  sr_phi_scan_instance_id = ?;
