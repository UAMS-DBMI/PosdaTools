-- Name: ShowAllHideEventsByCollectionSite
-- Schema: posda_files
-- Columns: ['file_id', 'user_name', 'time_of_change', 'prior_visibility', 'new_visibility', 'reason_for']
-- Args: ['collection', 'site']
-- Tags: ['old_hidden']
-- Description: Show All Hide Events by Collection, Site

select
  file_id,
  user_name,
  time_of_change,
  prior_visibility,
  new_visibility,
  reason_for
from
   file_visibility_change 
where file_id in (
  select file_id 
  from ctp_file 
  where project_name = ? and site_name = ? 
)