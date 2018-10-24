-- Name: SeriesInHierarchyBySeries
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['series_instance_uid']
-- Tags: ['by_series_instance_uid', 'posda_files', 'sops']
-- Description: Get Collection, Site, Patient, Study Hierarchy in which series resides
-- 

select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_patient natural join
  file_study natural join
  file_series natural join
  ctp_file
where file_id in (
  select
    distinct file_id
  from
    file_series natural join ctp_file
  where
    series_instance_uid = ? and visibility is null
)
order by
  project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid
