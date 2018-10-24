-- Name: PatientStudySeriesHierarchyByCollectionSiteWithDateRange
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['collection', 'site', 'from', 'to']
-- Tags: ['Hierarchy', 'apply_disposition']
-- Description: Construct list of files in a collection, site in a Patient, Study, Series Hierarchy with upload times within a date range

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_study natural join 
  ctp_file natural join 
  file_series natural join 
  file_patient
where 
  file_id in (
    select distinct file_id
    from 
      ctp_file  natural join
      file_import natural join
      import_event
    where project_name = ? and site_name = ? and
    visibility is null and
    import_time > ? and import_time < ?
  )
order by patient_id, study_instance_uid, series_instance_uid