-- Name: PatientStudySeriesHierarchyByCollectionNotMatchingSeriesDesc
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['collection', 'exclude_series_descriptions_matching']
-- Tags: ['Hierarchy']
-- Description: Construct list of series in a collection in a Patient, Study, Series Hierarchy excluding matching SeriesDescriptons

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_study natural join ctp_file natural join file_series natural join file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file natural join file_series
    where project_name = ? and series_description not like ?
  )
order by patient_id, study_instance_uid, series_instance_uid