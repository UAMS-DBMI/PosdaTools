-- Name: GetTiffValueSeen
-- Schema: posda_phi_simple
-- Columns: ['tiff_value_seen_id']
-- Args: ['value']
-- Tags: ['phi_reports']
-- Description: Get the value_id of a Tag value for a previously seen Tiff Tag value
--

select tiff_value_seen_id from tiff_value_seen where value = ?;
