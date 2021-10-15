-- Name: FaceBoxInFileNiftiDefacingBySubprocessWithSeries
-- Schema: posda_files
-- Columns: ['file_id', 'nifti_file_id', 'series_instance_uid']
-- Args: ['subprocess_invocation_id']
-- Tags: ['nifti']
-- Description: List of files not found faces in defacing
-- 

select
  three_d_rendered_face_box as file_id, from_nifti_file as nifti_file_id,
  nffs. series_instance_uid
from 
  file_nifti_defacing fnd, nifti_file_from_series nffs
where
  fnd.from_nifti_file = nffs.nifti_file_id and
  three_d_rendered_face_box is not null and subprocess_invocation_id = ?
