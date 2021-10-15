-- Name: FilesByImportNameLike
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['import_comment_like']
-- Tags: ['nifti']
-- Description: Get the ImportEventId of an import based on import_comment
-- 

select 
  file_id from file_import
where import_event_id in(
  select import_event_id
  from import_event
  where import_comment like ?
)