-- Name: RoiInfoByFileId
-- Schema: posda_files
-- Columns: ['roi_id', 'for_uid', 'max_x', 'max_y', 'max_z', 'min_x', 'min_y', 'min_z', 'roi_name', 'roi_description', 'roi_interpreted_type']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  distinct roi_id, for_uid,
  max_x, max_y, max_z,
  min_x, min_y, min_z,
  roi_name, roi_description , roi_interpreted_type
from
  roi natural join file_structure_set
where file_id = ?