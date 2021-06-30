-- Name: NiftiFileRenderingsByNiftiId
-- Schema: posda_files
-- Columns: ['proj_type', 'jpeg_file_id']
-- Args: ['nifti_file_id']
-- Tags: ['Nifti']
-- Description: Get rendered slices for nifti file
-- 

select
  proj_type, jpeg_file_id
from
  nifti_jpeg_projection
where
  nifti_file_id = ?