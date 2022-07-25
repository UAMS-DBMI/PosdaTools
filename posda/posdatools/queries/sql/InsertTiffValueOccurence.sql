-- Name: InsertTiffValueOccurence
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['tiff_tag_seen_id','tiff_value_seen_id','tiff_phi_scan_instance_id', 'file_id']
-- Tags: ['phi_reports']
-- Description: Record an occurance of a Tag and Value pair in a PHI Report instance
--
--

insert into tiff_tag_value_occurence (tiff_tag_seen_id,tiff_value_seen_id,tiff_phi_scan_instance_id,file_id) values (?,?,?,?);
