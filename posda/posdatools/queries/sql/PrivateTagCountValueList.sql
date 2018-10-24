-- Name: PrivateTagCountValueList
-- Schema: posda_phi
-- Columns: ['vr', 'value', 'element_signature', 'num_files', 'disposition']
-- Args: []
-- Tags: ['postgres_status', 'PrivateTagKb', 'NotInteractive']
-- Description: Get List of Private Tags with All Values
-- 

select 
  distinct element_signature, vr, value, private_disposition as disposition, count(*) as num_files
from
  element_signature natural join scan_element natural join seen_value
where
  is_private
group by element_signature, vr, value, private_disposition
order by element_signature, vr, value