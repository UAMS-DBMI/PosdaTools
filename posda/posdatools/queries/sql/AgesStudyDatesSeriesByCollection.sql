-- Name: AgesStudyDatesSeriesByCollection
-- Schema: posda_files
-- Columns: ['patient_id', 'study_date', 'patient_age', 'series_instance_uid', 'modality']
-- Args: ['collection']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select
  distinct patient_id, study_date, patient_age, series_instance_uid, modality
from
  file_patient natural join file_series natural join file_study natural join ctp_file
where
  project_name = ?

