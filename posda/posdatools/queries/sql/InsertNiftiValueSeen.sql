-- Name: InsertNiftiValueSeen
-- Schema: posda_phi_simple
-- Columns: ['nifti_value_seen_id']
-- Args: ['value']
-- Tags: ['phi_reports']
-- Description: Insert a Tag value for a newly seen Nifti Tag value
--

insert into nifti_value_seen (value) values (?) returning nifti_value_seen_id;
