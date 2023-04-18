-- Name: SeriesInHierarchyBySeriesExtended
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_description', 'series_date', 'modality', 'num_files']
-- Args: ['series_instance_uid']
-- Tags: ['by_series_instance_uid', 'posda_files', 'sops']
-- Description: Get Collection, Site, Patient, Study Hierarchy in which series resides
-- 

select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  study_date,
  study_description,
  series_instance_uid,
  series_description,
  series_date,
  modality,
  count(distinct file_id) as num_files
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
    series_instance_uid = ?
)
group by
  collection, site, patient_id, study_instance_uid, study_date,
  study_description, series_instance_uid, series_description,
  series_date, modality
order by
  project_name, site_name, patient_id,
  study_instance_uid, series_instance_uid
