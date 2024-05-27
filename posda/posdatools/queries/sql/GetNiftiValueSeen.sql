-- Name: GetNiftiValueSeen
-- Schema: posda_phi_simple
-- Columns: ['nifti_value_seen_id']
-- Args: ['value']
-- Tags: ['phi_reports']
-- Description: Get the value_id of a Tag value for a previously seen Nifti Tag value
--

select nifti_value_seen_id from nifti_value_seen where value = ?;
