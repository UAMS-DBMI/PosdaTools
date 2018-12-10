-- Name: AllSeenValuesByElementVr
-- Schema: posda_phi_simple
-- Columns: ['value']
-- Args: ['element_sig_pattern', 'vr']
-- Tags: ['NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Get the relevant features of an element_signature in posda_phi_simple schema

select distinct value 
from element_value_occurance natural join value_seen natural join element_seen
where element_sig_pattern = ? and vr = ? order by value