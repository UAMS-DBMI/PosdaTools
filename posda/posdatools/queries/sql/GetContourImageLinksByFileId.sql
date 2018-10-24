-- Name: GetContourImageLinksByFileId
-- Schema: posda_files
-- Columns: ['roi_id', 'sop_instance_uid', 'sop_class_uid', 'contour_type', 'num_contours', 'num_points']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  distinct roi_id,
  linked_sop_instance_uid as sop_instance_uid,
  linked_sop_class_uid as sop_class_uid,
  contour_type,
  count(distinct contour_digest) as num_contours,
  sum(num_points) as num_points
from
 file_roi_image_linkage
where file_id = ?
group by roi_id, linked_sop_instance_uid, linked_sop_class_uid, contour_type