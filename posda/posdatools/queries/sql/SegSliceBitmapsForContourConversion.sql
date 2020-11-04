-- Name: SegSliceBitmapsForContourConversion
-- Schema: posda_files
-- Columns: ['seg_bitmap_file_id', 'seg_slice_bitmap_file_id', 'rows', 'cols']
-- Args: []
-- Tags: ['SegBitmaps']
-- Description: get a seg_bitmap_file_id row for an existing file in the file_table
-- 

select
  seg_bitmap_file_id, seg_slice_bitmap_file_id, rows, cols
from
  seg_bitmap_file sbf natural join seg_slice_bitmap_file ssbf
where total_one_bits > 0 
  and not exists (
    select 
      seg_slice_bitmap_file_id
    from
      seg_slice_to_contour sstc
    where
      sstc.seg_slice_bitmap_file_id = ssbf.seg_slice_bitmap_file_id and
      sbf.rows = sstc.rows and
      sbf.cols = sstc.cols
  );