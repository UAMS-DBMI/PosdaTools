-- Name: CreateSimpleElementValueOccurance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['element_seen_id', 'value_seen_id', 'series_scan_instance_id', 'scan_instance_id']
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Create a new scanned value instance

insert into element_value_occurance(
element_seen_id, value_seen_id, series_scan_instance_id, phi_scan_instance_id
)values(?, ?, ?, ?)