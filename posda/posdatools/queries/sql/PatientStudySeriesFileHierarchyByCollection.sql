-- Name: PatientStudySeriesFileHierarchyByCollection
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'path']
-- Args: ['collection']
-- Tags: ['Hierarchy']
-- Description: Construct list of files in a collection in a Patient, Study, Series Hierarchy

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  root_path || '/' || rel_path as path
from
  file_study natural join ctp_file natural join file_series natural join file_patient
  natural join file_sop_common natural join file_location
  natural join file_storage_root
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ?
  )
order by patient_id, study_instance_uid, series_instance_uid