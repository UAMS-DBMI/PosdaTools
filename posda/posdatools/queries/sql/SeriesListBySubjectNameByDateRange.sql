-- Name: SeriesListBySubjectNameByDateRange
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_date', 'series_description', 'modality', 'dicom_file_type', 'num_files']
-- Args: ['patient_id', 'from', 'to']
-- Tags: ['find_series', 'for_tracy', 'backlog_round_history']
-- Description: Get List of Series by Subject Name

select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  modality, 
  dicom_file_type, 
  count(distinct file_id) as num_files
from 
  file_patient natural join
  file_series natural join
  file_study natural join
  dicom_file natural join
  ctp_file join file_import using(file_id)
  join import_event using(import_event_id)
where 
  patient_id = ?
  and visibility is null
  and import_time > ? 
  and import_time < ?
group by 
  collection,
  site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_date,
  series_description,
  modality,
  dicom_file_type;