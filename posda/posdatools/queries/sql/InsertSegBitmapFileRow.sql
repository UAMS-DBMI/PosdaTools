-- Name: InsertSegBitmapFileRow
-- Schema: posda_files
-- Columns: []
-- Args: ['seg_bitmap_file_id', 'number_segmentations', 'num_slices', 'rows', 'cols', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'frame_of_reference_uid', 'pixel_offset']
-- Tags: ['SegBitmaps']
-- Description: Create a seg_bitmap_file_id row for an exiting file in the file_table
-- 

insert into seg_bitmap_file(
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
) values (
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?
);