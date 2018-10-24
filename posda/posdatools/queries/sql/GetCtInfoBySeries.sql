-- Name: GetCtInfoBySeries
-- Schema: posda_files
-- Columns: ['kvp', 'scan_options', 'data_collection_diameter', 'reconstruction_diameter', 'dist_source_to_detect', 'dist_source_to_pat', 'gantry_tilt', 'rotation_dir', 'exposure_time', 'filter_type', 'generator_power', 'convolution_kernal', 'table_feed_per_rot']
-- Args: ['series_instance_uid']
-- Tags: ['populate_posda_files', 'bills_test']
-- Description: Gets count of all files which are PET's which haven't been imported into file_pt_image yet.
-- 
-- 

select 
  distinct 
  kvp,
  scan_options,
  data_collection_diameter,
  reconstruction_diameter,
  dist_source_to_detect,
  dist_source_to_pat,
  gantry_tilt,
  rotation_dir,
  exposure_time,
  filter_type,
  generator_power, 
  convolution_kernal,
  table_feed_per_rot
from file_ct_image natural join file_patient natural join file_series natural join ctp_file 
where series_instance_uid = ? and visibility is null
