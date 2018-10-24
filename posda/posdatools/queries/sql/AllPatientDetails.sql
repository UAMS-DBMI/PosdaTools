-- Name: AllPatientDetails
-- Schema: posda_files
-- Columns: ['collection', 'site', 'visibility', 'patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files']
-- Args: []
-- Tags: ['adding_ctp', 'find_patients']
-- Description: Get Series in A Collection
-- 

select
  distinct project_name as collection,
  site_name as site,
  visibility,
  patient_id,
  patient_name,
  study_instance_uid,
  study_date,
  series_instance_uid,
  modality,
  count (distinct file_id) as num_files
from
  file_patient natural left join
  file_study natural left join
  file_series natural left join
  ctp_file
where
  project_name is null and site_name is null and visibility is null
group by
  project_name, site_name, visibility, 
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  project_name, site_name, patient_id, study_date,
  modality
