-- Name: TagsSeenSimple
-- Schema: posda_phi_simple
-- Columns: ['element_sig_pattern', 'vr', 'is_private', 'private_disposition', 'tag_name']
-- Args: []
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint']
-- Description: Get all the data from tags_seen in posda_phi_simple database
-- 

select
  element_sig_pattern, vr, is_private, private_disposition, tag_name
from
  element_seen order by element_sig_pattern