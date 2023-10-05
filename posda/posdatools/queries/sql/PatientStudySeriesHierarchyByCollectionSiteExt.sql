-- Name: PatientStudySeriesHierarchyByCollectionSiteExt
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files']
-- Args: ['collection', 'site']
-- Tags: ['Hierarchy', 'phi_simple', 'simple_phi']
-- Description: Construct list of files in a collection, site in a Patient, Study, Series Hierarchy

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  count (distinct file_id) as num_files
from
  file_study natural join
  ctp_file natural join
  dicom_file natural join
  file_series natural join
  file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ?
  )
group by patient_id, study_instance_uid, series_instance_uid,
  dicom_file_type, modality
order by patient_id, study_instance_uid, series_instance_uid