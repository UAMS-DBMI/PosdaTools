-- Name: ImageDefacingResultsBySubprocess
-- Schema: posda_files
-- Columns: ['file_id', 'defaced_file_id', 'three_d', 'face_box', 'defaced', 'success', 'error_code']
-- Args: ['subprocess_invocation_id']
-- Tags: ['nifti']
-- Description: List of files not found faces in defacing
-- 

select
 from_nifti_file as file_id,
 to_nifti_file as defaced_file_id,
 three_d_rendered_face as three_d,
 three_d_rendered_face_box as face_box,
 three_d_rendered_defaced as defaced,
 success,
 error_code
from file_nifti_defacing
where
   subprocess_invocation_id = ? and
   success is not null
