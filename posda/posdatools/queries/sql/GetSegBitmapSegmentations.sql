-- Name: GetSegBitmapSegmentations
-- Schema: posda_files
-- Columns: ['seg_bitmap_file_id', 'segmentation_num', 'label', 'description', 'color', 'algorithm_type', 'algorithm_name', 'segmented_category', 'segmented_type']
-- Args: ['seg_bitmap_file_id']
-- Tags: ['SegBitmaps']
-- Description: get all seg_bitmap_segmentation rows for a seg_bitmap file
-- 

select
  seg_bitmap_file_id,
  segmentation_num,
  label,
  description,
  color,
  algorithm_type,
  algorithm_name,
  segmented_category,
  segmented_type
from
  seg_bitmap_segmentation
where
  seg_bitmap_file_id = ?
order by segmentation_num