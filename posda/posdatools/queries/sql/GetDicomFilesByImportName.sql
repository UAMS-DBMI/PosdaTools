-- Name: GetDicomFilesByImportName
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['import_comment']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id
-- 
-- NB: Normally there should be no file_id (i.e. file has not been imported)

select
  distinct file_id                                                                                                                                                                                                                                                                                                                                                                                                                                from
  import_event natural join file_import natural join dicom_file
where
  import_type = 'posda-api import' and import_comment = ?