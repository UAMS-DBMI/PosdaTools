-- Name: InFileNifti
-- Schema: posda_files
-- Columns: ['count']
-- Args: ['file_id']
-- Tags: ['nifti']
-- Description: Is file in file_nifti table?
-- 

select
  count(*) as count
from file_nifti
where file_id = ?
