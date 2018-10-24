-- Name: PopulateFilePtImageRow
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'pti_trigger_time', 'pti_frame_time', 'pti_intervals_acquired', 'pti_intervals_rejected', 'pti_reconstruction_diameter', 'pti_gantry_detector_tilt', 'pti_table_height', 'pti_fov_shape', 'pti_fov_dimensions', 'pti_collimator_type', 'pti_convoution_kernal', 'pti_actual_frame_duration', 'pti_energy_range_lower_limit', 'pti_energy_range_upper_limit', 'pti_radiopharmaceutical', 'pti_radiopharmaceutical_volume', 'pti_radiopharmaceutical_start_time', 'pti_radiopharmaceutical_stop_time', 'pti_radionuclide_total_dose', 'pti_radionuclide_half_life', 'pti_radionuclide_positron_fraction', 'pti_number_of_slices', 'pti_number_of_time_slices', 'pti_type_of_detector_motion', 'pti_image_id', 'pti_series_type', 'pti_units', 'pti_counts_source', 'pti_reprojection_method', 'pti_randoms_correction_method', 'pti_attenuation_correction_method', 'pti_decay_correction', 'pti_reconstruction_method', 'pti_detector_lines_of_response_used', 'pti_scatter_correction_method', 'pti_axial_mash', 'pti_transverse_mash', 'pti_coincidence_window_width', 'pti_secondary_counts_type', 'pti_frame_reference_time', 'pti_primary_counts_accumulated', 'pti_secondary_counts_accumulated', 'pti_slice_sensitivity_factor', 'pti_decay_factor', 'pti_dose_calibration_factor', 'pti_scatter_fraction_factor', 'pti_dead_time_factor', 'pti_image_index']
-- Tags: ['populate_posda_files', 'bills_test']
-- Description: Get Series in A Collection
-- 

insert into file_pt_image(
  file_id,
  pti_trigger_time,
  pti_frame_time,
  pti_intervals_acquired,
  pti_intervals_rejected,
  pti_reconstruction_diameter,
  pti_gantry_detector_tilt,
  pti_table_height,
  pti_fov_shape,
  pti_fov_dimensions,
  pti_collimator_type,
  pti_convoution_kernal,
  pti_actual_frame_duration,
  pti_energy_range_lower_limit,
  pti_energy_range_upper_limit,
  pti_radiopharmaceutical,
  pti_radiopharmaceutical_volume,
  pti_radiopharmaceutical_start_time,
  pti_radiopharmaceutical_stop_time,
  pti_radionuclide_total_dose,
  pti_radionuclide_half_life,
  pti_radionuclide_positron_fraction,
  pti_number_of_slices,
  pti_number_of_time_slices,
  pti_type_of_detector_motion,
  pti_image_id,
  pti_series_type,
  pti_units,
  pti_counts_source,
  pti_reprojection_method,
  pti_randoms_correction_method,
  pti_attenuation_correction_method,
  pti_decay_correction,
  pti_reconstruction_method,
  pti_detector_lines_of_response_used,
  pti_scatter_correction_method,
  pti_axial_mash,
  pti_transverse_mash,
  pti_coincidence_window_width,
  pti_secondary_counts_type,
  pti_frame_reference_time,
  pti_primary_counts_accumulated,
  pti_secondary_counts_accumulated,
  pti_slice_sensitivity_factor,
  pti_decay_factor,
  pti_dose_calibration_factor,
  pti_scatter_fraction_factor,
  pti_dead_time_factor,
  pti_image_index
) values (
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
  ?, ?, ?, ?, ?, ?, ?, ?, ?
)