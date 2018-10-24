-- Name: GetSimpleValuesForTag
-- Schema: posda_phi_simple
-- Columns: ['value']
-- Args: ['tag', 'vr']
-- Tags: ['tag_values']
-- Description: Find Values for a given tag, vr in posda_phi_simple
-- 

select
  distinct value
from
  element_seen natural join
  element_value_occurance natural join
  value_seen
where element_sig_pattern = ? and vr = ?
