-- Name: GetSegBitmapRelatedSops
-- Schema: posda_files
-- Columns: ['seg_bitmap_file_id', 'series_instance_uid', 'sop_instance_uid']
-- Args: ['seg_bitmap_file_id']
-- Tags: ['SegBitmaps']
-- Description: Get series and sops of files related to a segmentation file (i.e. from referenced series sequence)
-- 

select
  seg_bitmap_file_id,
  series_instance_uid,
  sop_instance_uid
from
  seg_bitmap_related_sops
where
  seg_bitmap_file_id = ?