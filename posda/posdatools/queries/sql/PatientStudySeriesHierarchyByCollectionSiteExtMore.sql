-- Name: PatientStudySeriesHierarchyByCollectionSiteExtMore
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files', 'first_loaded', 'last_loaded']
-- Args: ['collection', 'site']
-- Tags: ['Hierarchy', 'phi_simple', 'simple_phi']
-- Description: Construct list of files in a collection, site in a Patient, Study, Series Hierarchy

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  count (distinct file_id) as num_files,
  min(import_time) as first_loaded,
  max(import_time) as last_loaded
from
  file_study natural join
  ctp_file natural join
  dicom_file natural join
  file_series natural join
  file_patient join
  file_import using(file_id) join
  import_event using(import_event_id)
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ?
  )
group by patient_id, study_instance_uid, series_instance_uid,
  dicom_file_type, modality
order by patient_id, study_instance_uid, series_instance_uid