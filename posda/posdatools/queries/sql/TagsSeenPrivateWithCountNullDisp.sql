-- Name: TagsSeenPrivateWithCountNullDisp
-- Schema: posda_phi
-- Columns: ['element_signature', 'vr', 'private_disposition', 'name_chain', 'num_values']
-- Args: []
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'phi_maint']
-- Description: Get all the data from tags_seen in posda_phi database
-- 

select
  distinct element_signature, 
  vr, 
  private_disposition, 
  name_chain, 
  count(distinct value) as num_values
from
  element_signature natural left join
  scan_element natural left join
  seen_value
where is_private and private_disposition is null
group by element_signature, vr, private_disposition, name_chain
order by element_signature, vr