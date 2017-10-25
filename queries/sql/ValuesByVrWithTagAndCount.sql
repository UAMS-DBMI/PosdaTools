-- Name: ValuesByVrWithTagAndCount
-- Schema: posda_phi
-- Columns: ['value', 'element_signature', 'private_disposition', 'num_files']
-- Args: ['scan_id', 'vr']
-- Tags: ['tag_usage']
-- Description: List of values seen in scan by VR (with count of elements)
-- 

select distinct value, element_signature, private_disposition, num_files from (
  select
    distinct value, element_signature, private_disposition, vr, count(*)  as num_files
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ? and vr = ?
  group by value, element_signature, vr
) as foo
order by value
