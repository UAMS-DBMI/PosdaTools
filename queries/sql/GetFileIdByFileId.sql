-- Name: GetFileIdByFileId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['file_id']
-- Tags: ['by_file_id', 'posda_files', 'slope_intercept']
-- Description: Get a Slope, Intercept for a particular file 
-- 

select
  file_id
from
  file
where
  file_id = ?
