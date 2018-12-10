-- Name: GetFilePathWithCollSitePatientStudySeries
-- Schema: posda_files
-- Columns: ['path', 'collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['file_id']
-- Tags: ['AllCollections', 'universal', 'public_posda_consistency']
-- Description: Get path to file by id

select
  root_path || '/' || rel_path as path,
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid
from
  file_location natural join file_storage_root natural join
  ctp_file natural join file_patient natural join file_study natural join file_series
where
  file_id = ?