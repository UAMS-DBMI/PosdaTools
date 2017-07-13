-- Name: ShowAllVisibilityChangesBySeriesInstance
-- Schema: posda_files
-- Columns: ['user_name', 'time_of_change', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files']
-- Args: ['series_instance_uid']
-- Tags: ['show_hidden']
-- Description: Show All Hide Events by Collection, Site

select
  distinct
  user_name,
  time_of_change,
  prior_visibility,
  new_visibility,
  reason_for,
  count (distinct file_id) as num_files
from
   file_visibility_change 
where file_id in (
  select distinct file_id 
  from file_series
  where series_instance_uid = ?
)
group by user_name, time_of_change,
  prior_visibility, new_visibility, reason_for
order by time_of_change