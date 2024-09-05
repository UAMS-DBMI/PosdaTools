-- Name: GetNiftiTagSeen
-- Schema: posda_phi_simple
-- Columns: ['nifti_tag_seen_id']
-- Args: ['tag_name']
-- Tags: ['phi_reports']
-- Description: 'Get the tag_id of a Tag name for a Nifti Tag'
--

select nifti_tag_seen_id from nifti_tag_seen where tag_name = ?;
