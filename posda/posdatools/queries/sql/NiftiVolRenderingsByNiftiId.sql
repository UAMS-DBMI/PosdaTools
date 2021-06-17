-- Name: NiftiVolRenderingsByNiftiId
-- Schema: posda_files
-- Columns: ['vol_num', 'proj_type', 'jpeg_file_id']
-- Args: ['nifti_file_id']
-- Tags: ['Nifti']
-- Description: Get rendered slices for nifti file
-- 

select
  vol_num, proj_type, jpeg_file_id
from
  nifti_jpeg_vol_projection
where
  nifti_file_id = ?