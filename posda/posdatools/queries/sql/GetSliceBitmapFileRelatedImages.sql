-- Name: GetSliceBitmapFileRelatedImages
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['seg_bitmap_file_id', 'seg_bitmap_slice_no']
-- Tags: ['SegBitmaps']
-- Description: All the SOPs related to a segmentation slice by seg_slice_bitmap_file_id and slice_no
-- 

select
  sop_instance_uid
from
  seg_slice_bitmap_file_related_image
where
  seg_bitmap_file_id = ? and
  seg_bitmap_slice_no = ?