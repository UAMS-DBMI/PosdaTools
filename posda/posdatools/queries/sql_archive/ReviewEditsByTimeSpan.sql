-- Name: ReviewEditsByTimeSpan
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'series_instance_uid', 'new_visibility', 'reason_for', 'earliest', 'latest', 'num_files']
-- Args: ['from', 'to']
-- Tags: ['Hierarchy', 'review_visibility_changes']
-- Description: Show all file visibility changes by series over a time range

select
  distinct project_name,
  site_name,
  series_instance_uid,
  new_visibility,
  reason_for,
  min(time_of_change) as earliest,
  max(time_of_change) as latest,
  count(*) as num_files
from
  file_visibility_change natural join
  ctp_file natural join
  file_series
where
  time_of_change > ? and time_of_change < ?
group by
  project_name,
  site_name,
  series_instance_uid,
  new_visibility,
  reason_for