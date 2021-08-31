-- Name: SRCreatePathValueOccurance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['sr_path_seen_id', 'value_seen_id', s'r_series_scan_instance_id','sr_phi_scan_instance_id']
-- Tags: ['Structured Report']
-- Description: Creates a new SR + value occurance
--

insert into sr_path_value_occurance(
sr_path_seen_id, value_seen_id, sr_series_scan_instance_id, sr_phi_scan_instance_id
)values(?, ?, ?, ?);
