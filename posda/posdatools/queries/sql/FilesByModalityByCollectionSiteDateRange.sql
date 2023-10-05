-- Name: FilesByModalityByCollectionSiteDateRange
-- Schema: posda_files
-- Columns: ['patient_id', 'modality', 'series_instance_uid', 'sop_instance_uid', 'path', 'earliest', 'latest']
-- Args: ['modality', 'collection', 'site', 'from', 'to']
-- Tags: ['FindSubjects', 'intake', 'FindFiles']
-- Description: Find All Files with given modality in Collection, Site

select
  distinct patient_id, modality, series_instance_uid, sop_instance_uid, 
  root_path || '/' || file_location.rel_path as path,
  min(import_time) as earliest,
  max(import_time) as latest
from
  file_patient natural join file_series natural join file_sop_common natural join ctp_file
  natural join file_location natural join file_storage_root
  join file_import using(file_id) join import_event using(import_event_id)
where
  modality = ? and
  project_name = ? and 
  site_name = ? and
  import_time > ? and import_time < ?
group by patient_id, modality, series_instance_uid, sop_instance_uid, path