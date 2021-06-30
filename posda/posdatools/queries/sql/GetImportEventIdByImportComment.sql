-- Name: GetImportEventIdByImportComment
-- Schema: posda_files
-- Columns: ['import_event_id']
-- Args: ['import_comment']
-- Tags: ['nifti']
-- Description: Get the ImportEventId of an import based on import_comment
-- 

select
  import_event_id
from
  import_event
where
  import_comment = ?