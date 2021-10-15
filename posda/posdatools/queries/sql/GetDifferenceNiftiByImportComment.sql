-- Name: GetDifferenceNiftiByImportComment
-- Schema: posda_files
-- Columns: ['difference_nifti_file_id']
-- Args: ['import_comment']
-- Tags: ['nifti']
-- Description: Get a report on defaced nifti files
-- 

select 
  file_id as difference_nifti_file_id
from
  import_event natural join file_import natural join file
where
  file_type like 'Nifti File%' and import_comment = ?