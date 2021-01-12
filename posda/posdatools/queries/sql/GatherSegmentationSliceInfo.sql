-- Name: GatherSegmentationSliceInfo
-- Schema: posda_files
-- Columns: ['seg_bitmap_slice_no', 'iop', 'ipp', 'total_one_bits', 'num_bare_points', 'sop_instance_uid', 'num_contours', 'num_points', 'seg_slice_bitmap_file_id', 'contour_slice_file_id']
-- Args: ['seg_bitmap_file_id', 'segmentation_number']
-- Tags: ['SegBitmaps']
-- Description: get a seg_bitmap_file_id row for an existing file in the file_table
-- 

select
  seg_bitmap_slice_no, iop, ipp, total_one_bits, num_bare_points,
  sop_instance_uid, num_contours, num_points, seg_slice_bitmap_file_id,
  contour_slice_file_id
from
  seg_slice_bitmap_file left join
  seg_slice_bitmap_file_related_image using(seg_bitmap_file_id, seg_bitmap_slice_no)
  left join seg_slice_to_contour using(seg_slice_bitmap_file_id)
where
  seg_bitmap_file_id = ? and segmentation_number = ?
order by seg_bitmap_slice_no