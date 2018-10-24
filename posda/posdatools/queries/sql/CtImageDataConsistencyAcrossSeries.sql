-- Name: CtImageDataConsistencyAcrossSeries
-- Schema: posda_files
-- Columns: ['kvp', 'scan_options', 'data_collection_diameter', 'reconstruction_diameter', 'dist_source_to_detect', 'dist_source_to_pat', 'gantry_tilt', 'table_height', 'rotation_dir', 'exposure_time', 'filter_type', 'generator_power', 'convolution_kernal', 'num_files']
-- Args: ['series_instance_uid']
-- Tags: ['populate_posda_files', 'ct_image_consistency']
-- Description: Get CT Series with CT Image Info by collection
-- 
-- 

select 
  distinct kvp, scan_options, data_collection_diameter, reconstruction_diameter,
  dist_source_to_detect, dist_source_to_pat,gantry_tilt, table_height,
  rotation_dir, exposure_time, exposure, filter_type, generator_power, convolution_kernal,
  count(distinct file_id) as num_files
from file_ct_image where file_id in (
  select file_id from file_series natural join ctp_file where series_instance_uid = ?
)
group by
  kvp, scan_options, data_collection_diameter, reconstruction_diameter,
  dist_source_to_detect, dist_source_to_pat,gantry_tilt, table_height,
  rotation_dir, exposure_time, exposure, filter_type, generator_power, convolution_kernal
