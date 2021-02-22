-- Name: GetStructSegsByStructId
-- Schema: posda_files
-- Columns: ['image_file_id', 'roi_num', 'segmentation_slice_file_id', 'path']
-- Args: ['structure_set_file_id']
-- Tags: ['StructContourToSlice']
-- Description: Get all rows in struct_contour_to_slice
-- 

select
    image_file_id,
    roi_num,
    segmentation_slice_file_id,
    root_path || '/' || rel_path as path
from
  struct_contours_to_slice scts, file_location fl, file_storage_root fsr
where
  scts.structure_set_file_id = ? and
  scts.segmentation_slice_file_id = fl.file_id and
  fsr.file_storage_root_id = fl.file_storage_root_id