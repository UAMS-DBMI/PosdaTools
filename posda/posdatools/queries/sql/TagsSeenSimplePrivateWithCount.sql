-- Name: TagsSeenSimplePrivateWithCount
-- Schema: posda_phi_simple
-- Columns: ['element_sig_pattern', 'vr', 'private_disposition', 'tag_name', 'num_values']
-- Args: []
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint']
-- Description: Get all the data from tags_seen in posda_phi_simple database
-- 

select 
  distinct element_sig_pattern,
  vr,
  private_disposition, tag_name,
  count(distinct value) as num_values
from
  element_seen natural left join
  element_value_occurance
  natural left join value_seen
where
  is_private 
group by element_sig_pattern, vr, private_disposition, tag_name
order by element_sig_pattern;