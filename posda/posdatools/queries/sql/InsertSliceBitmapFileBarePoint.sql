-- Name: InsertSliceBitmapFileBarePoint
-- Schema: posda_files
-- Columns: []
-- Args: ['seg_bitmap_file_id', 'seg_bitmap_slice_no', 'point']
-- Tags: ['SegBitmaps']
-- Description: Insert a bare point in a segmentation slice by seg_slice_bitmap_file_id
-- 

insert into seg_slice_bitmap_bare_point (
  seg_bitmap_file_id,
  seg_bitmap_slice_no,
  point
) values (
  ?, ?, ?
)