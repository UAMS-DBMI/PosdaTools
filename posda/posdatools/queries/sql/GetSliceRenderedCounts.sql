-- Name: GetSliceRenderedCounts
-- Schema: posda_files
-- Columns: ['roi_num', 'num_slices']
-- Args: ['structure_set_file_id']
-- Tags: ['StructContourToSlice']
-- Description: Get count of rendered slices for an roi in a structure set
-- 

select 
  distinct roi_num, count(distinct image_file_id) as num_slices
from
  struct_contours_to_slice
where 
  structure_set_file_id = ?
group by roi_num;