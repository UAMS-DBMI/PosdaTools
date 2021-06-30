-- Name: CreateNiftiJpegSlice
-- Schema: posda_files
-- Columns: []
-- Args: ['nifti_file_id', 'vol_num', 'slice_number', 'flipped', 'jpeg_file_id']
-- Tags: ['nifti']
-- Description: Create row in nifti_jpeg_slice table
-- 

insert into nifti_jpeg_slice(
  nifti_file_id, vol_num, slice_number, flipped, jpeg_file_id
) values (
  ?, ?, ?, ?, ?
)