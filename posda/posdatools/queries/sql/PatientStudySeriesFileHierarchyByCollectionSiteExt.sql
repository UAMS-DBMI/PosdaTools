-- Name: PatientStudySeriesFileHierarchyByCollectionSiteExt
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'count']
-- Args: ['collection', 'site']
-- Tags: ['Hierarchy']
-- Description: Construct list of files in a collection, site in a Patient, Study, Series, with Modality of file

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality,
  count(*)
from
  file_study natural join
  dicom_file natural join
  ctp_file natural join
  file_series natural join 
  file_patient natural join
  file_sop_common
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ? and visibility is null
  )
group by
  patient_id,
  study_instance_uid,
  series_instance_uid,
  dicom_file_type,
  modality
order by patient_id, study_instance_uid, series_instance_uid