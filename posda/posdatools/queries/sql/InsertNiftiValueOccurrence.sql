-- Name: InsertNiftiValueOccurrence
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['nifti_tag_seen_id', 'nifti_value_seen_id', 'nifti_phi_scan_instance_id', 'file_id']
-- Tags: ['nifti','phi_reports']
-- Description: Record an occurrence of a Tag and Value pair in a PHI Report instance
--
--

insert into nifti_tag_value_occurrence (nifti_tag_seen_id, nifti_value_seen_id, nifti_phi_scan_instance_id, file_id) values (?,?,?,?)
