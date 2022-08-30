-- Name: InsertTiffValueSeen
-- Schema: posda_phi_simple
-- Columns: ['tiff_value_seen_id']
-- Args: ['value']
-- Tags: ['phi_reports']
-- Description: Insert a Tag value for a newly seen Tiff Tag value
--

insert into tiff_value_seen ( value) values (?) returning tiff_value_seen_id;
