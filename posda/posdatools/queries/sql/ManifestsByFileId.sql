-- Name: ManifestsByFileId
-- Schema: posda_files
-- Columns: ['cm_collection', 'cm_site', 'cm_patient_id', 'cm_study_date', 'cm_series_instance_uid', 'cm_study_description', 'cm_series_description', 'cm_modality', 'cm_num_files']
-- Args: ['file_id']
-- Tags: ['activity_timepoint_support', 'manifests']
-- Description: Get a manifest from database
-- 
-- 

select
  cm_collection,
  cm_site,
  cm_patient_id,
  cm_study_date,
  cm_series_instance_uid,
  cm_study_description,
  cm_series_description,
  cm_modality,
  cm_num_files
from
  ctp_manifest_row
where
  file_id = ?
order by 
  cm_index