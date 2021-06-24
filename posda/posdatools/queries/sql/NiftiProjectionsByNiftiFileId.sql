-- Name: NiftiProjectionsByNiftiFileId
-- Schema: posda_files
-- Columns: ['proj_type', 'jpeg_file_id', 'path']
-- Args: ['nifti_file_id']
-- Tags: ['Nifti']
-- Description: Get jpeg_file_ids for nifti projections for a nifti file
-- 

select
  proj_type, jpeg_file_id, root_path || '/' || rel_path as path
from
  nifti_jpeg_projection nj, file_storage_root sr, file_location fl
where
  nj.nifti_file_id = ? and fl.file_id = nj.jpeg_file_id and 
  fl.file_storage_root_id = sr.file_storage_root_id