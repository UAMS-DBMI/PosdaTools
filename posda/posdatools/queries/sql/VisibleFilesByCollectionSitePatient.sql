-- Name: VisibleFilesByCollectionSitePatient
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'file_id', 'visibility']
-- Args: ['collection', 'site', 'patient_id']
-- Tags: ['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select
  distinct project_name as collection,
  site_name as site,
  patient_id, file_id, visibility
from
  ctp_file natural join file_patient
where
  project_name = ? and
  site_name = ? and
  patient_id = ? and
  visibility is null
order by collection, site, patient_id

