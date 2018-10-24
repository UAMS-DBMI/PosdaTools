-- Name: FileWithInfoBySopInPublic
-- Schema: public
-- Columns: ['frame_of_ref', 'iop', 'ipp', 'pixel_spacing', 'pixel_rows', 'pixel_columns']
-- Args: ['sop_instance_uid']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  frame_of_reference_uid as frame_of_ref,
  image_orientation_patient as iop,
  image_position_patient as ipp,
  pixel_spacing,
  i_rows as pixel_rows,
  i_columns as pixel_columns
from
  general_image i, general_series s
where
  i.general_series_pk_id = s.general_series_pk_id and
  sop_instance_uid = ?