-- Name: FilesByModalityByCollectionSite
-- Schema: posda_files
-- Columns: ['patient_id', 'modality', 'series_instance_uid', 'sop_instance_uid', 'path']
-- Args: ['modality', 'project_name', 'site_name']
-- Tags: ['FindSubjects', 'intake', 'FindFiles']
-- Description: Find All Files with given modality in Collection, Site

select
  distinct patient_id, modality, series_instance_uid, sop_instance_uid, root_path || '/' || rel_path as path
from
  file_patient natural join file_series natural join file_sop_common natural join ctp_file
  natural join file_location natural join file_storage_root
where
  modality = ? and
  project_name = ? and 
  site_name = ? and
  visibility is null