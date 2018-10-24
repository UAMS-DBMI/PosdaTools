-- Name: HideEvents
-- Schema: posda_files
-- Columns: ['when_done', 'reason_for', 'user_name', 'num_files']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'hide_events']
-- Description: Add a filter to a tab

select
  distinct date_trunc('day', time_of_change) as when_done, 
  reason_for,
  user_name, 
  count(*) as num_files
from
  file_visibility_change
group by when_done, reason_for, user_name
order by when_done desc