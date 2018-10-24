-- Name: TagsSeen
-- Schema: posda_phi
-- Columns: ['element_signature', 'vr', 'is_private', 'private_disposition', 'name_chain']
-- Args: []
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint']
-- Description: Get all the data from tags_seen in posda_phi database
-- 

select
  element_signature, vr, is_private, private_disposition, name_chain
from
  element_signature order by element_signature