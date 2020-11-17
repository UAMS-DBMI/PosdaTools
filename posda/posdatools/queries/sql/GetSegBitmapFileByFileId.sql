-- Name: GetSegBitmapFileByFileId
-- Schema: posda_files
-- Columns: ['seg_bitmap_file_id', 'number_segmentations', 'num_slices', 'rows', 'cols', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'frame_of_reference_uid', 'pixel_offset']
-- Args: ['seg_bitmap_file_id']
-- Tags: ['SegBitmaps']
-- Description: get a seg_bitmap_file_id row for an existing file in the file_table
-- 

select
  seg_bitmap_file_id,
  number_segmentations,
  num_slices,
  rows,
  cols,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  frame_of_reference_uid,
  pixel_offset
from
  seg_bitmap_file
where
  seg_bitmap_file_id = ?