-- Name: SegSliceBitmapsWithoutPng
-- Schema: posda_files
-- Columns: ['seg_bitmap_file_id', 'seg_slice_bitmap_file_id', 'rows', 'cols']
-- Args: []
-- Tags: ['SegBitmaps']
-- Description: get a seg_bitmap_file_id row for an existing file in the file_table
-- 

select
  seg_bitmap_file_id, seg_slice_bitmap_file_id, rows, cols
from
  seg_slice_bitmap_file join seg_bitmap_file using (seg_bitmap_file_id)
where
  total_one_bits > 0 and seg_slice_png_file_id is null 
   