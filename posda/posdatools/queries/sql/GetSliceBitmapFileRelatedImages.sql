-- Name: GetSliceBitmapFileRelatedImages
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['seg_slice_bitmap_file_id', 'seg_bitmap_file_id']
-- Tags: ['SegBitmaps']
-- Description: All the SOPs related to a segmentation slice by seg_slice_bitmap_file_id
-- 

select
  sop_instance_uid
)
from
  seg_slice_bitmap_file_related_image
where
  seg_slice_bitmap_file_id = ? and
  seg_bitmap_file_id = ?