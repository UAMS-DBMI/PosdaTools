-- Name: GetSliceBitmapFileBarePoints
-- Schema: posda_files
-- Columns: ['point']
-- Args: ['seg_bitmap_file_id', 'seg_bitmap_slice_no']
-- Tags: ['SegBitmaps']
-- Description: All the bare points in a segmentation slice by seg_slice_bitmap_file_id
-- 

select
  point
from
  seg_slice_bitmap_bare_point
where
  seg_bitmap_file_id = ? and
  seg_bitmap_slice_no = ?
  