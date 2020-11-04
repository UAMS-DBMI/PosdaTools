-- Name: GetContoursAndBitmapsForSegFile
-- Schema: posda_files
-- Columns: ['seg_slice_bitmap_file_id', 'segmentation_number', 'seg_bitmap_slice_no', 'related_sop', 'label', 'description', 'color', 'segmented_type', 'segmented_category', 'rows', 'cols', 'ipp', 'frame_of_reference_uid', 'total_one_bits', 'num_bare_points', 'contour_slice_file_id', 'num_contours', 'num_points']
-- Args: ['seg_bitmap_file_id']
-- Tags: ['SegBitmaps']
-- Description: get a seg_bitmap_file_id row for an existing file in the file_table
-- 

select 
  ssbf.seg_slice_bitmap_file_id, segmentation_number, ssbf.seg_bitmap_slice_no, 
  ssbfri.sop_instance_uid as related_sop,
  label, description, color, segmented_type, segmented_category,
  sbm.rows, sbm.cols, ipp, frame_of_reference_uid,
  total_one_bits, num_bare_points,
  contour_slice_file_id, num_contours, num_points
from
  seg_bitmap_file sbm,
  seg_bitmap_segmentation sbs,
  seg_slice_bitmap_file ssbf,
  seg_slice_bitmap_file_related_image ssbfri,
  seg_slice_to_contour sstc
where
  sbm.seg_bitmap_file_id = ? and
  sbm.seg_bitmap_file_id = sbs.seg_bitmap_file_id and
  sbm.seg_bitmap_file_id = ssbf.seg_bitmap_file_id and
  ssbf.seg_slice_bitmap_file_id = sstc.seg_slice_bitmap_file_id
  and sbm.rows = sstc.rows and sbm.cols = sstc.cols and
  sbs.segmentation_num = ssbf.segmentation_number
  and ssbfri.seg_bitmap_slice_no = ssbf.seg_bitmap_slice_no