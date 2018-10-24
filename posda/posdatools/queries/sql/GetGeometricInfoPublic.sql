-- Name: GetGeometricInfoPublic
-- Schema: public
-- Columns: ['sop_instance_uid', 'image_orientation_patient', 'image_position_patient', 'pixel_spacing', 'i_rows', 'i_columns']
-- Args: ['sop_instance_uid']
-- Tags: ['LinkageChecks', 'BySopInstance']
-- Description: Get Geometric Information by Sop Instance UID from public

select
  sop_instance_uid, image_orientation_patient, image_position_patient,
  pixel_spacing, i_rows, i_columns
from
  general_image
where
  sop_instance_uid = ?
