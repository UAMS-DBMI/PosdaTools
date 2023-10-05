-- Name: FilesByCollectionSitePatientWithVisibility
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'visibility']
-- Args: ['collection', 'site', 'patient_id']
-- Tags: ['hide_events']
-- Description: Get List of files for Collection, Site with visibility

select
  distinct
  file_id,
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  sop_instance_uid,
  file_id,
  visibility
from
  ctp_file
  join file_patient using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
where 
  project_name = ?
  and site_name = ?
  and patient_id = ?