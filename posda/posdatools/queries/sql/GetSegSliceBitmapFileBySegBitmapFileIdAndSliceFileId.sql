-- Name: GetSegSliceBitmapFileBySegBitmapFileIdAndSliceFileId
-- Schema: posda_files
-- Columns: ['seg_slice_bitmap_file_id', 'seg_bitmap_file_id', 'segmentation_number', 'iop', 'ipp', 'total_one_bits', 'num_bare_points']
-- Args: ['seg_slice_bitmap_file_id', 'seg_bitmap_file_id']
-- Tags: ['SegBitmaps']
-- Description: get seg_slice_bitmap_file rows for an existing seg_bitmap_file in the file_table and seg_bitmap_file table
-- by seg_slice_bitmap_file_id and seg_bitmap_file_id
-- 

select
  seg_slice_bitmap_file_id,
  seg_file_id,
  segmentation_number,
  iop,
  ipp,
  total_one_bits,
  num_bare_points
from
  seg_slice_bitmap_file
where
  seg_slice_bitmap_file_id = ? and
  seg_bitmap_file_id = ?