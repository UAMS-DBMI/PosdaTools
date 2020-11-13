-- Name: InsertSliceBitmapFileRelatedSop
-- Schema: posda_files
-- Columns: []
-- Args: ['seg_bitmap_file_id', 'seg_bitmap_slice_no', 'sop_instance_uid']
-- Tags: ['SegBitmaps']
-- Description: Insert a seg_slice_bitmap_file_related_image row
-- 

insert into seg_slice_bitmap_file_related_image (
  seg_bitmap_file_id,
  seg_bitmap_slice_no,
  sop_instance_uid
) values (
  ?, ?, ?
)