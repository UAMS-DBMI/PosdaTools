-- Name: DistinctSegSliceBitmapsWithNoPng
-- Schema: posda_files
-- Columns: ['seg_slice_bitmap_file_id', 'rows', 'cols', 'num_entries']
-- Args: []
-- Tags: ['SegBitmaps']
-- Description: get a seg_bitmap_file_id row for an existing file in the file_table
-- 

select
  distinct seg_slice_bitmap_file_id, rows, cols, count(*) as num_entries
from
  seg_slice_bitmap_file join seg_bitmap_file using (seg_bitmap_file_id)
where
  seg_slice_png_file_id is null and total_one_bits = 0
group by seg_slice_bitmap_file_id, rows, cols
   