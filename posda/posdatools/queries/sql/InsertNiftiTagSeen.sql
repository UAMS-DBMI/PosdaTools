-- Name: InsertNiftiTagSeen
-- Schema: posda_phi_simple
-- Columns: ['nifti_tag_seen_id']
-- Args: ['tag_name']
-- Tags: ['phi_reports']
-- Description: Insert a Nifti Tag
--

insert into nifti_tag_seen (tag_name) values (?) returning nifti_tag_seen_id;
