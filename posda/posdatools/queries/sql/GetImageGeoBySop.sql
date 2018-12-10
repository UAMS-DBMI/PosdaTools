-- Name: GetImageGeoBySop
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'image_orientation_patient', 'image_position_patient', 'pixel_spacing', 'i_rows', 'i_columns']
-- Args: ['sop_instance_uid']
-- Tags: ['LinkageChecks', 'BySopInstance']
-- Description: Get Geometric Information by Sop Instance UID from posda

select 
  distinct sop_instance_uid, iop as image_orientation_patient,
  ipp as image_position_patient,
  pixel_spacing,
  pixel_rows as i_rows,
  pixel_columns as i_columns
from
  file_sop_common join
  ctp_file using(file_id) join
  file_patient using (file_id) join
  file_image using (file_id) join 
  file_series using (file_id) join
  file_study using (file_id) join
  image using (image_id) join
  file_image_geometry using (file_id) join
  image_geometry using (image_geometry_id) 
where 
  sop_instance_uid = ? and visibility is null
