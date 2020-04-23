-- Name: SeriesByMatchingImportEventsWithEventInfoAndPatientId
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_type', 'import_comment', 'import_time', 'patient_id', 'series_instance_uid']
-- Args: ['import_comment_like', 'import_type_like']
-- Tags: ['find_series', 'import_events']
-- Description:  Get Series by Import Events by matching 
--

select distinct import_event_id, import_type, import_comment, import_time, patient_id, series_instance_uid from
  file_series natural join file_import natural join import_event natural join file_patient
where import_event_id in (
  select
    import_event_id
  from 
    import_event
  where
    import_comment like ? 
    and
    import_type like ?
)
order by import_event_id desc

