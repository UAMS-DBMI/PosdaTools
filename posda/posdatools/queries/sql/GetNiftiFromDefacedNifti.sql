-- Name: GetNiftiFromDefacedNifti
-- Schema: posda_files
-- Columns: ['converted_file_id']
-- Args: ['defaced_nifti_file_id']
-- Tags: ['nifti']
-- Description: Get a report on defaced nifti files
-- 

select 
  from_nifti_file as converted_file_id
from 
  file_nifti_defacing
where
 to_nifti_file = ?