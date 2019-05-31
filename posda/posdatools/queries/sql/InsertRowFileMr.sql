-- Name: InsertRowFileMr
-- Schema: posda_files
-- Columns: []
-- Args: ['mr_scanning_seq', 'mr_scanning_var', 'mr_scan_options', 'mr_acq_type', 'mr_slice_thickness', 'mr_repetition_time', 'mr_echo_time', 'mr_magnetic_field_strength', 'mr_spacing_between_slices', 'mr_echo_train_length', 'mr_software_version', 'mr_flip_angle', 'mr_nominal_pixel_spacing', 'mr_patient_position', 'mr_acquisition_number', 'mr_instance_number', 'mr_smallest_pixel', 'mr_largest_pixel', 'mr_window_center', 'mr_window_width', 'mr_rescale_intercept', 'mr_rescale_slope', 'mr_rescale_type', 'file_id']
-- Tags: ['mr_images']
-- Description: Insert a Row in file_mr
-- 

insert into file_mr(
  mr_scanning_seq, mr_scanning_var, mr_scan_options,
  mr_acq_type, mr_slice_thickness, mr_repetition_time,
  mr_echo_time,  mr_magnetic_field_strength, mr_spacing_between_slices,
  mr_echo_train_length, mr_software_version, mr_flip_angle,
  mr_nominal_pixel_spacing, mr_patient_position, mr_acquisition_number,
  mr_instance_number, mr_smallest_pixel, mr_largest_value,
  mr_window_center, mr_window_width, mr_rescale_intercept,
  mr_rescale_slope, mr_rescale_type, file_id
) values (
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?
)

