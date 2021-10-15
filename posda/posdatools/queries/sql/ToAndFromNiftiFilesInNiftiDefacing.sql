-- Name: ToAndFromNiftiFilesInNiftiDefacing
-- Schema: posda_files
-- Columns: ['from_nifti_file', 'to_nifti_file', 'subprocess_invocation_id']
-- Args: ['file_nifti_defacing_id']
-- Tags: ['nifti']
-- Description: For a file_nifti_defacing, get the 
-- from_nifti_file, to_nifti_file and subprocess_invocation_id
-- if the to_nifti_file is not null
-- 

select
 from_nifti_file, to_nifti_file, subprocess_invocation_id
from file_nifti_defacing
where
  to_nifti_file is not null and
  file_nifti_defacing_id = ?
