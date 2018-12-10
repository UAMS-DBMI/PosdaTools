-- Name: RoiInfoByFileIdWithCountsAndOffsets
-- Schema: posda_files
-- Columns: ['roi_id', 'for_uid', 'linked_sop_instance_uid', 'max_x', 'max_y', 'max_z', 'min_x', 'min_y', 'min_z', 'roi_name', 'roi_description', 'roi_interpreted_type', 'contour_real_file_offset', 'contour_length', 'path']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  roi_id, for_uid, linked_sop_instance_uid,
  max_x, max_y, max_z,
  min_x, min_y, min_z,
  roi_name, roi_description , roi_interpreted_type,
  contour_file_offset + coalesce (data_set_start, 0) as contour_real_file_offset,
  contour_length,
  root_path || '/' || rel_path as path
from
  roi natural join file_roi_image_linkage natural join file_location natural join file_storage_root natural join file_meta
where file_id = ?
