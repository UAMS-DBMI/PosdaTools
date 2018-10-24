-- Name: AllPatientDetailsWithNoCtpByImportEvent
-- Schema: posda_files
-- Columns: ['patient_id', 'patient_name', 'study_instance_uid', 'study_date', 'series_instance_uid', 'modality', 'num_files']
-- Args: ['import_event_id']
-- Tags: ['adding_ctp', 'find_patients', 'no_ctp_details']
-- Description: List patient details without CTP, selected by import event
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
 and file_id in (select file_id from file_import where import_event_id = ?)
group by
  patient_id, patient_name, study_instance_uid, study_date,
  series_instance_uid, modality
order by 
  patient_id, study_date,
  modality
