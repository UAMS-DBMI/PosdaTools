-- Name: InsertTiffValueOccurrence
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['tiff_tag_seen_id','tiff_value_seen_id','tiff_phi_scan_instance_id', 'page_id','file_id']
-- Tags: ['pathology','phi_reports']
-- Description: Record an occurrence of a Tag and Value pair in a PHI Report instance
--
--

insert into tiff_tag_value_occurrence (tiff_tag_seen_id,tiff_value_seen_id,tiff_phi_scan_instance_id,page_id, file_id) values (?,?,?,?,?)
