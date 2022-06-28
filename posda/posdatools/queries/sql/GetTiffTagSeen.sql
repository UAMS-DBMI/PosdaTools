-- Name: GetTiffTagSeen
-- Schema: posda_phi_simple
-- Columns: ['tiff_tag_seen_id']
-- Args: ['tag_name']
-- Tags: ['phi_reports']
-- Description: 'Get the tag_id of a Tag name for a Tiff Tag'
--

select tiff_tag_seen_id from tiff_tag_seen where tag_name = ?;
