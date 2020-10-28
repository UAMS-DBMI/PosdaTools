-- Name: InsertSegBitmapSegmentation
-- Schema: posda_files
-- Columns: []
-- Args: ['seg_bitmap_file_id', 'segmentation_num', 'label', 'description', 'color', 'algorithm_type', 'algorithm_name', 'segmented_category', 'segmented_type']
-- Tags: ['SegBitmaps']
-- Description: create a seg_bitmap_segmentation row for a segmenation in a seg_bitmap file
-- 

insert into seg_bitmap_segmentation(
  seg_bitmap_file_id,
  segmentation_num,
  label,
  description,
  color,
  algorithm_type,
  algorithm_name,
  segmented_category,
  segmented_type
) values (
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?
)