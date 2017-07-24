-- Name: PrivateTagsToBeDeleted
-- Schema: posda_phi_simple
-- Columns: ['tag']
-- Args: []
-- Tags: ['AllCollections', 'queries']
-- Description: Private tags to be deleted

select distinct element_sig_pattern as tag from element_seen where is_private and private_disposition = 'd' order by element_sig_pattern;

