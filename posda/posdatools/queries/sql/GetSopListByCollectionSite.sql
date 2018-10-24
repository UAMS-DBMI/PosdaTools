-- Name: GetSopListByCollectionSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid']
-- Args: ['collection', 'site']
-- Tags: ['bills_test', 'comparing_posda_to_public']
-- Description: Get a full list of sops with collection, site, patient, study_instance_uid and series_instance_uid
-- by collection, site
-- 
-- <bold>This may generate a large number of rows</bold>

select 
  distinct project_name as collection, site_name as site,
  patient_id, study_instance_uid, series_instance_uid,
  sop_instance_uid
from
  ctp_file natural join file_patient natural join
  file_study natural join file_series natural join file_sop_common
where
  project_name = ? and site_name = ? and visibility is null;