-- Name: HideEventInfo
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'num_files']
-- Args: ['day_of_change', 'reason_for', 'user_name']
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'hide_events']
-- Description: Add a filter to a tab

select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  count(distinct file_id) as num_files
from 
  ctp_file natural join
  file_series natural join 
  file_patient
where file_id in (
select
  distinct file_id
from
  file_visibility_change
where
  date_trunc('day', time_of_change) = ? and
  reason_for = ? and
  user_name = ?
)
group by
  collection, site, patient_id, series_instance_uid
order by
  collection, site, patient_id, series_instance_uid