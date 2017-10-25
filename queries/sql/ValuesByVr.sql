-- Name: ValuesByVr
-- Schema: posda_phi
-- Columns: ['value', 'count']
-- Args: ['scan_id', 'vr']
-- Tags: ['tag_usage']
-- Description: List of values seen in scan by VR (with count of elements)
-- 

select distinct value, count(*) from (
  select
    distinct value, element_signature, vr
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ? and vr = ?
) as foo
group by value
order by value
