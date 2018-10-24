-- Name: PatientStudySeriesHierarchyByCollectionSiteWithCounts
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'num_files']
-- Args: ['collection', 'site']
-- Tags: ['Hierarchy', 'apply_disposition']
-- Description: Construct list of files in a collection, site in a Patient, Study, Series Hierarchy

select distinct
  patient_id,
  study_instance_uid,
  series_instance_uid,
  count(distinct file_id) as num_files
from
  file_study natural join ctp_file natural join file_series natural join file_patient
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ? and site_name = ? and
    visibility is null
  )
group by patient_id, study_instance_uid, series_instance_uid
order by patient_id, study_instance_uid, series_instance_uid