-- Name: PatientAndFileCountByImportCommentAndDateRange
-- Schema: posda_files
-- Columns: ['patient_id', 'num_files']
-- Args: ['import_comment_like', 'import_type_like', 'from', 'to']
-- Tags: ['find_series', 'import_events']
-- Description: Get a list of PatientId's and file_counts by params.
-- 
-- This will permit eventimportComment & date range to get you a list of patid and filecount per patid so that batchActivities can then be made with a list of patid.
-- 

select 
  distinct patient_id, count(distinct file_id) as num_files
from
  file_patient natural join file_import
where import_event_id in (
  select import_event_id from import_event
  where
    import_comment like ? and
    import_type like ? and 
    import_time > ? and import_time < ?
) group by patient_id
