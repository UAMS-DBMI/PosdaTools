-- Name: SeriesByMatchingImportEventsAndDateRangeWithEventInfoAndPatientID
-- Schema: posda_files
-- Columns: ['import_type', 'import_comment', 'patient_id', 'series_instance_uid']
-- Args: ['import_comment_like', 'import_type_like', 'from', 'to']
-- Tags: ['find_series', 'import_events']
-- Description: Get Series by Import Events by matching 

select
  distinct  import_type, import_comment, patient_id, series_instance_uid
from
  file_patient natural join file_series natural join file_import natural join import_event
where import_event_id in (
  select
    import_event_id
  from 
    import_event
  where
    import_comment like ? 
    and
    import_type like ?
    and 
    import_time > ?
    and
    import_time < ?
)
order by patient_id, series_instance_uid
