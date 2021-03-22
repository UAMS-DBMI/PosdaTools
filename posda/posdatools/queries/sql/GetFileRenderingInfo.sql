-- Name: GetFileRenderingInfo
-- Schema: posda_files
-- Columns: ['file_path', 'pixel_data_offset', 'data_set_start', 'pixel_data_length', 'slope', 'intercept', 'window_center', 'window_width', 'win_lev_desc', 'pixel_rows', 'pixel_columns', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'photometric_interpretation', 'samples_per_pixel', 'number_of_frames', 'planar_configuration']
-- Args: ['file_id']
-- Tags: ['dicom_rendering']
-- Description: Get Information necessary to render a DICOM image by file_id
-- 

select
  distinct fsr.root_path || '/' || fl.rel_path as file_path,
  df.pixel_data_offset, fm.data_set_start,
  df.pixel_data_length, si.slope, si.intercept,
  wl.window_center, wl.window_width,
  wl.win_lev_desc,
  i.pixel_rows, i.pixel_columns,
  i.bits_allocated, i.bits_stored,
  i.high_bit, i.pixel_representation,
  i.photometric_interpretation,
  i.samples_per_pixel, i.number_of_frames,
  i.planar_configuration
from
  dicom_file df join file_location fl using(file_id)
  left join file_meta fm using(file_id)
  join file_storage_root fsr using (file_storage_root_id)
  join file_image fi using (file_id)
  join image i using (image_id)
  join file_image_geometry fig using (file_id)
  join image_geometry ig using (image_geometry_id)
  join file_win_lev fwl using (file_id)
  join window_level wl using (window_level_id)
  join file_slope_intercept using(file_id)
  left join slope_intercept si using(slope_intercept_id)
where
 file_id = ?