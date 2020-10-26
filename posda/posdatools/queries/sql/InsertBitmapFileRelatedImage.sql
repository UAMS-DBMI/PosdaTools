-- Name: InsertBitmapFileRelatedImage
-- Schema: posda_files
-- Columns: []
-- Args: ['seg_slice_bitmap_file_id', 'sop_instance_uid']
-- Tags: ['SegBitmaps']
-- Description: Add a row to the seg_slice_bitmap_file_related_image table
-- 

insert into seg_slice_bitmap_file_related_image(
  seg_slice_bitmap_file_id,
  sop_instance_uid
)
values (
  ?, ?
)
