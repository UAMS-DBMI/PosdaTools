-- Name: NiftiSlicesByNiftiFile
-- Schema: posda_files
-- Columns: ['vol_num', 'slice_number', 'flipped', 'jpeg_file_id']
-- Args: ['nifti_file_id']
-- Tags: ['Nifti']
-- Description: Get rendered slices for nifti file
-- 

select
  vol_num, slice_number, flipped, jpeg_file_id
from
  nifti_jpeg_slice
where
  nifti_file_id = ?