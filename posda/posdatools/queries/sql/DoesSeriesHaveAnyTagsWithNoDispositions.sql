-- Name: DoesSeriesHaveAnyTagsWithNoDispositions
-- Schema: posda_phi_simple
-- Columns: ['series_instance_uid']
-- Args: ['series_instance_uid']
-- Tags: ['PrivateDispositions']
-- Description: Determine if this series has any tags with no disposition
-- 

select distinct series_instance_uid 
from
  series_scan_instance 
where series_scan_instance_id in (
  select series_scan_instance_id 
  from element_value_occurance
  where element_seen_id in (
    select element_seen_id from element_seen 
    where 
      is_private and private_disposition is null
  )
  and series_scan_instance_id in (
      select series_scan_instance_id from series_scan_instance 
      where series_instance_uid = ?
  )
)