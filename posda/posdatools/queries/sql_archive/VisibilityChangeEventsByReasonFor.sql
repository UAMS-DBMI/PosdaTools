-- Name: VisibilityChangeEventsByReasonFor
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'when_done', 'user_name', 'prior_visibility', 'new_visibility', 'reason_for', 'num_files', 'num_series']
-- Args: ['reason_for']
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'hide_events', 'show_hidden']
-- Description: Add a filter to a tab

select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  date_trunc('hour', time_of_change) as when_done,
  user_name, prior_visibility, new_visibility, reason_for, count(distinct file_id) as num_files,
  count (distinct series_instance_uid) as num_series
from
   ctp_file natural join file_patient natural join file_series natural join file_visibility_change 
where reason_for = ?
group by
 collection, site, patient_id, when_done, user_name, prior_visibility, new_visibility, reason_for
order by when_done desc