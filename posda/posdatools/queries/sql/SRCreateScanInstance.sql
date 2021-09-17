-- Name: SRCreateScanInstance
-- Schema: posda_phi_simple
-- Columns: ['sr_phi_scan_instance_id']
-- Args: ['description']
-- Tags: ['Structured Report']
-- Description: Creates a new SR san instance
--

insert into sr_phi_scan_instance (description, start_time) values( ?, now()) returning sr_phi_scan_instance_id;
