-- Name: GetDefacedNiftiFileIdFromOriginal
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['from_nifti_file']
-- Tags: ['Nifti']
-- Description: Get the defaced nifti file id from an original nifti_file_id
-- 

select 
  to_nifti_file as file_id
from
 file_nifti_defacing
where
  from_nifti_file = ?