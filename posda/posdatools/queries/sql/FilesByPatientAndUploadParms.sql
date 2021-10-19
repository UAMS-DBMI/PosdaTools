-- Name: FilesByPatientAndUploadParms
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['import_comment_like', 'import_type_like', 'from', 'to', 'patient_id']
-- Tags: ['find_series', 'import_events']
-- Description: Get a list of file_id's by patient_id and upload parms
-- 
-- Used by script CreateActivityListFromPatientCountAndUploadSpecSpreadsheet.pl
-- to create a timepoint from uploaded spreadsheet produced by query
-- PatientAndFileCountByImportCommentAndDateRange and then analyzed to construct
-- batches
-- 

select 
  distinct file_id
from
  file_patient natural join file_import
where import_event_id in (
  select import_event_id from import_event
  where
    import_comment like ? and
    import_type like ? and 
    import_time > ? and import_time < ?
) and patient_id = ?