-- Name: ElementsWithMultipleVRs
-- Schema: posda_phi
-- Columns: ['element_signature', 'count']
-- Args: ['scan_id']
-- Tags: ['tag_usage']
-- Description: List of Elements with multiple VRs seen
-- 

select element_signature, count from (
  select element_signature, count(*)
  from (
    select
      distinct element_signature, vr
    from
      scan_event natural join series_scan
      natural join scan_element natural join element_signature
      natural join equipment_signature
    where
      scan_event_id = ?
  ) as foo
  group by element_signature
) as foo
where count > 1
