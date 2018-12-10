-- Name: RoiInfoByFileIdWithCounts
-- Schema: posda_files
-- Columns: ['roi_id', 'for_uid', 'linked_sop_instance_uid', 'max_x', 'max_y', 'max_z', 'min_x', 'min_y', 'min_z', 'roi_name', 'roi_description', 'roi_interpreted_type', 'num_contours']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  distinct roi_id, for_uid, linked_sop_instance_uid,
  max_x, max_y, max_z,
  min_x, min_y, min_z,
  roi_name, roi_description , roi_interpreted_type,
  count(*) as num_contours
from
  roi natural join file_roi_image_linkage 
where file_id = ?
group by 
  roi_id, for_uid, linked_sop_instance_uid,
  max_x, max_y, max_z,
  min_x, min_y, min_z,
  roi_name,
  roi_description, roi_interpreted_type