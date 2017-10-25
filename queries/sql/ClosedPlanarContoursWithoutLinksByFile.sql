-- Name: ClosedPlanarContoursWithoutLinksByFile
-- Schema: posda_files
-- Columns: ['roi_id', 'roi_name']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  distinct roi_id,
  roi_name
from
  file_structure_set natural join
  structure_set natural join
  roi natural join 
  roi_contour r
where
  file_id =? and 
  geometric_type = 'CLOSED_PLANAR' and 
  not exists (
    select roi_contour_id from contour_image ci where ci.roi_contour_id = r.roi_contour_id
  )