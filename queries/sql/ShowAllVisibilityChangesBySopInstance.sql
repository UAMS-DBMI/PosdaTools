-- Name: ShowAllVisibilityChangesBySopInstance
-- Schema: posda_files
-- Columns: ['file_id', 'user_name', 'time_of_change', 'prior_visibility', 'new_visibility', 'reason_for']
-- Args: ['sop_instance_uid']
-- Tags: ['show_hidden']
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
  from file_sop_common
  where sop_instance_uid = ?
)
order by time_of_change