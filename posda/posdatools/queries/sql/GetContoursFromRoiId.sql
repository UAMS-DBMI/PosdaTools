-- Name: GetContoursFromRoiId
-- Schema: posda_files
-- Columns: ['roi_contour_id', 'contour_num', 'geometric_type', 'number_of_points', 'linked_image_sop_class', 'linked_image_sop_instance', 'linked_image_frame_number']
-- Args: ['roi_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get List of ROI's in a structure Set
-- 
-- 

select
  roi_contour_id, contour_num, geometric_type, 
  number_of_points, sop_class as linked_image_sop_class,
  sop_instance as linked_image_sop_instance, 
  frame_number as linked_image_frame_number
from
  roi_contour natural left join contour_image
where roi_id = ?