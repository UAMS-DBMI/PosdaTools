-- Name: FilesForDispositionsByActivity
-- Schema: posda_files
-- Columns: ['file_id', 'collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'modality', 'path']
-- Args: ['activity_id']
-- Tags: ['PrivateDispositions']
-- Description: Files in Activity Timepoint for Applying Dispositions
-- 

select
  distinct file_id, project_name as collection, site_name as site, patient_id, 
  study_instance_uid, series_instance_uid,
  sop_instance_uid, modality,  root_path || '/' || rel_path as path
from
  activity_timepoint_file natural join file_patient natural join file_study
  natural join file_series natural join file_sop_common
  natural left join ctp_file
  natural join file_location natural join file_storage_root
where
  activity_timepoint_id = (
    select max(activity_timepoint_id) from activity_timepoint where activity_id = ?
  )