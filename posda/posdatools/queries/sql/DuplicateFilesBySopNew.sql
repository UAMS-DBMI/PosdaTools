-- Name: DuplicateFilesBySopNew
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'sop_instance_uid', 'modality', 'file_id', 'file_path', 'num_uploads', 'first_upload', 'last_upload']
-- Args: ['sop_instance_uid', 'activity_timepoint_id']
-- Tags: ['duplicates']
-- Description: Counts query by Collection, Site
-- 

select
  distinct
    project_name as collection, site_name as site,
    patient_id, sop_instance_uid, modality, file_id,
    root_path || '/' || file_location.rel_path as file_path,
    count(*) as num_uploads,
    min(file_import_time) as first_upload, 
    max(file_import_time) as last_upload
from
  activity_timepoint_file natural join 
  file_patient left join ctp_file using(file_id)
  join file_sop_common using(file_id)
  join file_series using(file_id)
  join file_location using(file_id)
  join file_storage_root using(file_storage_root_id)
  join file_import using (file_id)
where
  sop_instance_uid = ? and activity_timepoint_id = ?
group by
  project_name, site_name, patient_id, sop_instance_uid, modality, 
  file_id, file_path
order by
  collection, site, patient_id, sop_instance_uid, modality
