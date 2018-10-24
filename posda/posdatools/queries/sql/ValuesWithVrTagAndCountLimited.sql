-- Name: ValuesWithVrTagAndCountLimited
-- Schema: posda_phi
-- Columns: ['vr', 'value', 'element_signature', 'num_files']
-- Args: ['scan_id']
-- Tags: ['tag_usage']
-- Description: List of values seen in scan by VR (with count of elements)
-- 

select distinct vr, value, element_signature, num_files from (
  select
    distinct vr, value, element_signature, count(*)  as num_files
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ? and
    vr not in (
      'AE', 'AT', 'DS', 'FL', 'FD', 'IS', 'OD', 'OF', 'OL', 'OW',
      'SL', 'SQ', 'SS', 'TM', 'UL', 'US'
    )
  group by value, element_signature, vr
) as foo
order by vr, value
