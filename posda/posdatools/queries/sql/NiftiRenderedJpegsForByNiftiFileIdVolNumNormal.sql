-- Name: NiftiRenderedJpegsForByNiftiFileIdVolNumNormal
-- Schema: posda_files
-- Columns: ['slice_number', 'jpeg_file_path']
-- Args: ['nifti_file_id', 'vol_num']
-- Tags: ['Nifti']
-- Description: Get rendered slices for nifti file and vol_num where not flipped
-- 

select
 slice_number,  r.root_path || '/' || l.rel_path as jpeg_file_path
from
  nifti_jpeg_slice, file_location l, file_storage_root r
where
  nifti_file_id = ?  and vol_num = ? and not flipped
  and jpeg_file_id = l.file_id and l.file_storage_root_id = r.file_storage_root_id