-- Name: PatientStudySeriesFileHierarchyInTimepoint
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'file_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['by_series_instance_uid', 'posda_files', 'sops']
-- Description: Get Patient, Study, Series Hierarchy with file_id for files in timepoint
-- 

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  file_id
from
  file_patient natural join
  file_study natural join
  file_series
where file_id in (
  select
    distinct file_id
  from
    activity_timepoint_file
  where
    activity_timepoint_id = ?
)
order by
  patient_id, study_instance_uid, series_instance_uid, file_id
