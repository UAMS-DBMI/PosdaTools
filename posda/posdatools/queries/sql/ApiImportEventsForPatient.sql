-- Name: ApiImportEventsForPatient
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_comment', 'import_time', 'duration', 'patient_id', 'num_images']
-- Args: ['import_comment_like', 'patient_id_like']
-- Tags: ['import_events']
-- Description: Get Import Events by matching comment

select
  import_event_id, import_comment, import_time,
  import_close_time - import_time as duration, patient_id,
  count(distinct file_id) as num_images
from 
  import_event natural join file_import natural join file_patient
where
  import_comment like ? and import_type = 'posda-api import' and patient_id like ?
group by import_event_id, import_comment, import_time, import_close_time, patient_id