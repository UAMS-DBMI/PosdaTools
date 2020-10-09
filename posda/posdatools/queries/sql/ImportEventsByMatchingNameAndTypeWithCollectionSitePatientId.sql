-- Name: ImportEventsByMatchingNameAndTypeWithCollectionSitePatientId
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_type', 'import_comment', 'import_time', 'duration', 'collection', 'site', 'patient', 'dicom_file_type', 'num_images']
-- Args: ['import_comment_like', 'import_type_like', 'from', 'to']
-- Tags: ['import_events']
-- Description: Get Import Events by matching comment
-- 

select
  import_event_id, import_type,
  import_comment, import_time, import_close_time - import_time as duration, 
  coalesce(project_name, 'UNKNOWN') as collection,
  coalesce(site_name, 'UNKNOWN') as site,
  patient_id as patient,
  coalesce(dicom_file_type, 'Not Known DICOM IOD') as dicom_file_type,
  count(distinct file_id) as num_images
from 
  import_event natural join file_import natural join file_patient
  natural left join ctp_file natural left join dicom_file
where
  import_comment like ? and import_type like ?
  and import_time > ? and import_time < ?
group by import_event_id, import_type, import_comment, import_time, import_close_time, collection, site, patient,
  dicom_file_type