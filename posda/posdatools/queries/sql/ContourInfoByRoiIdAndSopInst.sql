-- Name: ContourInfoByRoiIdAndSopInst
-- Schema: posda_files
-- Columns: ['contour_file_offset', 'contour_length', 'contour_digest', 'num_points', 'contour_type']
-- Args: ['linked_sop_instance_uid', 'roi_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  contour_file_offset,
  contour_length,
  contour_digest,
  num_points,
  contour_type
from
 file_roi_image_linkage 
where
  linked_sop_instance_uid =? and roi_id = ?
