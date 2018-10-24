-- Name: FileWithInfoBySopInPosda
-- Schema: posda_files
-- Columns: ['frame_of_ref', 'iop', 'ipp', 'pixel_spacing', 'pixel_rows', 'pixel_columns']
-- Args: ['sop_instance_uid']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select 
  file_for.for_uid as frame_of_ref,
  iop, 
  ipp,
  pixel_spacing,
  pixel_rows,
  pixel_columns
from
  file_sop_common natural join ctp_file
  natural join file_for natural join file_image
  join image_geometry using (image_id)
  join image using (image_id)
where
  sop_instance_uid = ?
  and visibility is null