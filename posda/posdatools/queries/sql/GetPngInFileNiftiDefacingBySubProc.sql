-- Name: GetPngInFileNiftiDefacingBySubProc
-- Schema: posda_files
-- Columns: ['count']
-- Args: ['file_id']
-- Tags: ['nifti']
-- Description: Is file_id from_nifti_file in file_nifti_defacing table?
-- 

select
  count(*) as count
from file_nifti_defacing
where from_nifti_file = ?
