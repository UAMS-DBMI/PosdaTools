-- Name: PrivateTagCountReport
-- Schema: posda_phi
-- Columns: ['element_signature', 'vr', 'times_seen', 'num_distinct_values']
-- Args: []
-- Tags: ['postgres_status', 'PrivateTagKb']
-- Description: Get List of all Private Tags ever scanned with occurance and distinct value counts

select 
  distinct element_signature, vr, count(*) as times_seen,
  count(distinct value) as num_distinct_values 
from
  element_signature natural join scan_element natural join seen_value
where
  is_private
group by element_signature, vr
order by element_signature, vr, times_seen, num_distinct_values;
