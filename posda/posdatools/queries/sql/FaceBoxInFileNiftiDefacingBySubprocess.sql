-- Name: FaceBoxInFileNiftiDefacingBySubprocess
-- Schema: posda_files
-- Columns: ['file_id', 'nifti_file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['nifti']
-- Description: List of files not found faces in defacing
-- 

select
  three_d_rendered_face_box as file_id, from_nifti_file as nifti_file_id
from file_nifti_defacing
where
  three_d_rendered_face_box is not null and subprocess_invocation_id = ?
