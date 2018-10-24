-- Name: GetSimpleSeriesScanId
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Get id of newly created series_scan_instance

select currval('series_scan_instance_series_scan_instance_id_seq') as id