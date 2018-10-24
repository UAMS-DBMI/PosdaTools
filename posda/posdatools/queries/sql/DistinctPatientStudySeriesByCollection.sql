-- Name: DistinctPatientStudySeriesByCollection
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files']
-- Args: ['collection']
-- Tags: ['by_collection', 'find_series', 'search_series', 'send_series']
-- Description: Get Series in A Collection
-- 

select distinct
  patient_id, 
  study_instance_uid,
  series_instance_uid, 
  dicom_file_type,
  modality, 
  count(distinct file_id) as num_files
from
  ctp_file
  natural join dicom_file
  natural join file_study
  natural join file_series
  natural join file_patient
where
  project_name = ? and
  visibility is null
group by
  patient_id, 
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality
  