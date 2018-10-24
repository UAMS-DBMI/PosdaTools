-- Name: AgesAndStudyDates
-- Schema: posda_files
-- Columns: ['patient_id', 'study_date', 'patient_age', 'num_series']
-- Args: ['collection']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select
  distinct patient_id, study_date, patient_age, count(distinct series_instance_uid) as num_series
from
  file_patient natural join file_series natural join file_study natural join ctp_file
where
  project_name = ? and visibility is null
group by
  patient_id, study_date, patient_age order by patient_id