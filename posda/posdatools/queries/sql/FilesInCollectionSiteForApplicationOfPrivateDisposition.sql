-- Name: FilesInCollectionSiteForApplicationOfPrivateDisposition
-- Schema: posda_files
-- Columns: ['file_id', 'path', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid']
-- Args: ['collection', 'site']
-- Tags: ['by_collection_site', 'find_files']
-- Description: Get everything you need to negotiate a presentation_context
-- for all files in a Collection Site
-- 

select
  distinct file_id, root_path || '/' || rel_path as path, 
  patient_id, study_instance_uid, series_instance_uid,
  sop_instance_uid
from
  file_location natural join file_storage_root natural join file_patient
  natural join ctp_file natural join file_study 
  natural join file_sop_common natural join file_series
  
where
  project_name = ? and site_name = ?
