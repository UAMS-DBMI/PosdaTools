-- Name: ShowAllHideEventsByCollectionSiteAlt
-- Schema: posda_files
-- Columns: ['user_name', 'hour_of_change', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files']
-- Args: ['collection', 'site']
-- Tags: ['old_hidden']
-- Description: Show All Hide Events by Collection, Site

select
 distinct
  user_name,
  date_trunc('hour',time_of_change) as hour_of_change,
  prior_visibility,
  new_visibility,
  reason_for,
  count(distinct file_id) as num_files
from
   file_visibility_change 
where file_id in (
  select file_id 
  from ctp_file 
  where project_name = ? and site_name = ?
  and visibility = 'hidden' 
)
group by user_name, hour_of_change, prior_visibility, new_visibility, reason_for