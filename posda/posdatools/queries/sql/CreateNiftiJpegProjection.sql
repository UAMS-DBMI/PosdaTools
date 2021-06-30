-- Name: CreateNiftiJpegProjection
-- Schema: posda_files
-- Columns: []
-- Args: ['nifti_file_id', 'proj_type', 'jpeg_file_id']
-- Tags: ['nifti']
-- Description: Create row in nifti_jpeg_vol_projection table
-- 

insert into nifti_jpeg_projection(
  nifti_file_id, proj_type, jpeg_file_id
) values (
  ?, ?, ?
)