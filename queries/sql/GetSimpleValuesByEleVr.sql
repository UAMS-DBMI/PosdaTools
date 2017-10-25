-- Name: GetSimpleValuesByEleVr
-- Schema: posda_phi_simple
-- Columns: ['value']
-- Args: ['tag', 'vr']
-- Tags: ['tag_values']
-- Description: Find Values for a given tag, vr in posda_phi_simple
-- 

select
  distinct value
from
  element_seen
  join element_value_occurance using(element_seen_id)
  join value_seen using(value_seen_id)
where element_sig_pattern = ? and vr = ?
