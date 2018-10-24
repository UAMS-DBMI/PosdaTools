-- Name: PatientStudySeriesFileHierarchyByCollectionSite
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'modality']
-- Args: ['collection', 'site']
-- Tags: ['Hierarchy']
-- Description: Construct list of files in a collection, site in a Patient, Study, Series, with Modality of file

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  modality
from
  file_study natural join ctp_file natural join file_series natural join file_patient
  natural join file_sop_common
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ? and visibility is null
  )
order by patient_id, study_instance_uid, series_instance_uid