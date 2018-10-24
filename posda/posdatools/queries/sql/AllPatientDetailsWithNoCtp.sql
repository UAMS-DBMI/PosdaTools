-- Name: AllPatientDetailsWithNoCtp
-- Schema: posda_files
-- Columns: ['patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files']
-- Args: []
-- Tags: ['adding_ctp', 'find_patients', 'no_ctp_details']
-- Description: Get Series in A Collection
-- 

select
  distinct 
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
  file_series f
where
 not exists (select file_id from ctp_file c where c.file_id = f.file_id)
group by
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  patient_id, study_date,
  modality
