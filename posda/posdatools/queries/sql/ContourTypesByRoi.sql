-- Name: ContourTypesByRoi
-- Schema: posda_files
-- Columns: ['geometric_type', 'num_contours', 'total_points']
-- Args: ['roi_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  distinct geometric_type,
  count(distinct roi_contour_id) as num_contours,
  sum(number_of_points) as total_points
from
 roi_contour
where roi_id = ?
group by geometric_type