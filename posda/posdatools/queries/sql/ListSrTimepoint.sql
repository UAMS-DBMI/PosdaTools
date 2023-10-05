-- Name: ListSrTimepoint
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'file_id', 'file_path']
-- Args: ['activity_id']
-- Tags: ['activity_timepoint']
-- Description: Get a list of SR type objects in current activity
--

select 
  distinct project_name as collection, site_name as site,
  patient_id, study_instance_uid, series_instance_uid,
  file_id, root_path || '/' || rel_path as file_path
from
  dicom_file natural join file_patient natural join file_series
  natural join file_study natural join ctp_file
  join file_location using (file_id) natural join file_storage_root
where
  dicom_file_type like '%SR%' and
  file_id in (
   select file_id from activity_timepoint_file
   where activity_timepoint_id = (
      select max(activity_timepoint_id) as activity_timepoint_id
      from activity_timepoint 
      where activity_id = ?
    )
  )