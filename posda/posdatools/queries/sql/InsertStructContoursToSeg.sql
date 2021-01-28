-- Name: InsertStructContoursToSeg
-- Schema: posda_files
-- Columns: []
-- Args: ['structure_set_file_id', 'image_file_id', 'roi_num', 'rows', 'cols', 'num_contours', 'num_points', 'total_one_bits', 'contour_slice_file_id', 'segmentation_slice_file_id', 'png_slice_file_id']
-- Tags: ['StructContourToSlice']
-- Description: Get all rows in struct_contour_to_slice
-- 

insert into struct_contours_to_slice(
    structure_set_file_id,
    image_file_id,
    roi_num,
    rows,
    cols,
    num_contours,
    num_points,
    total_one_bits,
    contour_slice_file_id,
    segmentation_slice_file_id,
    png_slice_file_id
) values (
    ?, ?, ?,
    ?, ?, ?,
    ?, ?, ?,
    ?, ?
)
 