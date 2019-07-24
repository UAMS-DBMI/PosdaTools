-- Name: FileNameReportByImportEvent
-- Schema: posda_files
-- Columns: ['file_id', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'modality', 'series_date', 'series_description', 'dicom_file_type', 'file_name']
-- Args: ['import_event_id']
-- Tags: ['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow']
-- Description: Counts query by Collection, Site
-- 

select
  file_id, patient_id,
  study_instance_uid, study_date, study_description, series_instance_uid,
  modality, series_date, series_description, dicom_file_type, file_name
from
  file_import natural join file_patient natural join file_series natural join
  file_study natural join dicom_file
where
  import_event_id = ?
order by file_name