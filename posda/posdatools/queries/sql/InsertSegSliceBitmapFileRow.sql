-- Name: InsertSegSliceBitmapFileRow
-- Schema: posda_files
-- Columns: ['num_bare_points']
-- Args: ['seg_slice_bitmap_file_id', 'seg_bitmap_file_id', 'segmentation_number', 'iop', 'ipp', 'total_one_bits', 'num_bare_points']
-- Tags: ['SegBitmaps']
-- Description: Insert a seg_slice_bitmap_file row exist file (extracted from seg_bitmap_file already in file_table
-- 

insert into seg_slice_bitmap_file (
  seg_slice_bitmap_file_id,
  seg_file_id,
  segmentation_number,
  iop,
  ipp,
  total_one_bits,
  num_bare_points
) values (
  ?, ?, ?,
  ?, ?, ?,
  ?
)