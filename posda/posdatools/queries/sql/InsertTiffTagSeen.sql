-- Name: InsertTiffTagSeen
-- Schema: posda_phi_simple
-- Columns: ['tiff_tag_seen_id']
-- Args: ['is_private','tag_name']
-- Tags: ['phi_reports']
-- Description: Insert a Tiff Tag
--

insert into tiff_tag_seen (is_private , tag_name) values (?, ?) returning tiff_tag_seen_id;
