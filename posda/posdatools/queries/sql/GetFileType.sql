-- Name: GetFileType
-- Schema: posda_files
-- Columns: ['file_type']
-- Args: ['file_id']
-- Tags: ['nifti']
-- Description: Get file_type of a file by file_id
-- 

select
  file_type
from
  file
where file_id = ?