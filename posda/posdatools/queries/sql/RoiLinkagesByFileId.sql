-- Name: RoiLinkagesByFileId
-- Schema: posda_files
-- Columns: ['roi_id', 'sop_instance_uid', 'contour_type']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  distinct roi_id,
  linked_sop_instance_uid as sop_instance_uid,
  contour_type
from
  file_roi_image_linkage
where file_id =?