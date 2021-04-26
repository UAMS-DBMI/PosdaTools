-- Name: AddPngToSegSliceBitmap
-- Schema: posda_files
-- Columns: []
-- Args: ['seg_slice_png_file_id', 'seg_slice_bitmap_file_id']
-- Tags: ['SegBitmaps']
-- Description: get a seg_bitmap_file_id row for an existing file in the file_table
-- 

update seg_slice_bitmap_file set
  seg_slice_png_file_id = ?
where
  seg_slice_bitmap_file_id = ?
