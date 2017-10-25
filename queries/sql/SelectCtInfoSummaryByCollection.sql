-- Name: SelectCtInfoSummaryByCollection
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'kvp', 'scan_options', 'data_collection_diameter', 'reconstruction_diameter', 'dist_source_to_detect', 'dist_source_to_pat', 'gantry_tilt', 'rotation_dir', 'exposure_time', 'filter_type', 'generator_power', 'convolution_kernal', 'table_feed_per_rot']
-- Args: ['collection']
-- Tags: ['populate_posda_files', 'bills_test']
-- Description: Gets count of all files which are PET's which haven't been imported into file_pt_image yet.
-- 
-- 

select 
  distinct 
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
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
  table_feed_per_rot,
  count(*) as num_files
from file_ct_image natural join file_patient natural join file_series natural join ctp_file 
where project_name = ? and visibility is null
group by
  collection,
  site,
  patient_id,
  series_instance_uid,
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
order by patient_id