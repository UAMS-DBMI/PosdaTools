-- Name: DualFileNameReportByImportEvent
-- Schema: posda_files
-- Columns: ['file_id', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'modality', 'series_date', 'series_description', 'dicom_file_type', 'file_name', 'path']
-- Args: ['import_event_id']
-- Tags: ['import_events']
-- Description: List of values seen in scan by ElementSignature with VR and count
-- 

select
  file_id, patient_id,
  study_instance_uid, study_date, study_description, series_instance_uid,
  modality, series_date, series_description, dicom_file_type, file_name,
  root_path || '/' || l.rel_path as path 
from
  file_import natural join file_patient natural join file_series natural join
  file_study natural join dicom_file join file_location l using(file_id) natural join
  file_storage_root
where
  import_event_id = ?
order by file_name