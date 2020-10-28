-- Name: InsertSegBitmapRelatedSops
-- Schema: posda_files
-- Columns: []
-- Args: ['seg_bitmap_file_id', 'series_instance_uid', 'sop_instance_uid']
-- Tags: ['SegBitmaps']
-- Description: Insert a row into seg_bitmap related_sops
-- 

insert into seg_bitmap_related_sops(
  seg_bitmap_file_id,
  series_instance_uid,
  sop_instance_uid
) values (
  ?, ?, ?
)