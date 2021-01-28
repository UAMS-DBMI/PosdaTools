-- Name: DeleteStructContoursToSegByRoiAndImageIdAndStructFileId
-- Schema: posda_files
-- Columns: []
-- Args: ['roi_num', 'image_file_id', 'structure_set_file_id']
-- Tags: ['StructContourToSlice']
-- Description: Get all rows in struct_contour_to_slice
-- 

delete from 
  struct_contours_to_slice
where
  roi_num = ? and
  image_file_id  = ? and
  structure_set_file_id = ?