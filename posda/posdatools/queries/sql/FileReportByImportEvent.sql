-- Name: FileReportByImportEvent
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'modality', 'series_date', 'dicom_file_type', 'num_files']
-- Args: ['import_event_id']
-- Tags: ['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow']
-- Description: Counts query by Collection, Site
-- 

select
  distinct project_name as collection, site_name as site, patient_id,
  study_instance_uid, study_date, study_description, series_instance_uid,
  modality, series_date, dicom_file_type, count(distinct file_id) as num_files
from
  file_import natural join file_patient natural join file_series natural join
  file_study natural join dicom_file natural left join ctp_file
where
  import_event_id = ?
group by
  collection, site, patient_id, study_instance_uid, study_date,
  study_description, series_instance_uid, modality, series_date, dicom_file_type;