-- Name: VrsSeen
-- Schema: posda_phi
-- Columns: ['vr', 'count']
-- Args: ['scan_id']
-- Tags: ['tag_usage']
-- Description: List of VR's seen in scan (with count)
-- 

select distinct vr, count(*) from (
  select
    distinct value, element_signature, vr
  from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
  where
    scan_event_id = ?
) as foo
group by vr
order by vr
