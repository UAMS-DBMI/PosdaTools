-- Name: PatientStudySeriesHierarchyByCollection
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['collection']
-- Tags: ['Hierarchy']
-- Description: Construct list of files in a collection in a Patient, Study, Series Hierarchy

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_study natural join ctp_file natural join file_series natural join file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and visibility is null
  )
order by patient_id, study_instance_uid, series_instance_uid