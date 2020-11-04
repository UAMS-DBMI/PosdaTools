-- Name: InsertIntoSegSliceToContour
-- Schema: posda_files
-- Columns: []
-- Args: ['seg_slice_bitmap_file_id', 'rows', 'cols', 'num_contours', 'num_points', 'contour_slice_file_id']
-- Tags: ['SegBitmaps']
-- Description: Add a row to the seg_slice_to_contour table
-- 

insert into seg_slice_to_contour(
  seg_slice_bitmap_file_id, rows, cols, num_contours,
  num_points, contour_slice_file_id
)
values (
  ?, ?, ?,
  ?, ?, ?
)
