-- Name: CompleteImportEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['import_event_id']
-- Tags: ['nifti']
-- Description: Close an import_event
-- 

update import_event
  set import_close_time = now()
where
  import_event_id = ?
