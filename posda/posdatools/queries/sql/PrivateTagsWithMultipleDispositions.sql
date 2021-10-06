-- Name: PrivateTagsWithMultipleDispositions
-- Schema: posda_phi_simple
-- Columns: ['element_sig_pattern', 'vr', 'id', 'disp', 'tag_name']
-- Args: []
-- Tags: ['PrivateDispositions']
-- Description: Get private tags with multiple dispositions
-- 

select
  element_sig_pattern, vr, element_seen_id as id, private_disposition as disp, tag_name
from
  element_seen
where element_sig_pattern in (select element_sig_pattern from (
select distinct element_sig_pattern, count(distinct private_disposition) as num_dispositions from element_seen where is_private group by element_sig_pattern) as foo where num_dispositions > 1)
order by element_sig_pattern