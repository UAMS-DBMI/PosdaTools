create table dicom_to_nifti_conversion(
  dicom_to_nifti_conversion_id serial,
  subprocess_invocation_id integer not null,
  activity_timepoint_id integer not null
);
create table nifti_file_from_series(
  nifti_file_from_series_id serial,
  dicom_to_nifti_conversion_id integer not null,
  series_instance_uid text not null,
  num_files_in_series integer not null,
  num_files_selected_from_series integer not null,
  dcm2nii_invoked boolean not null,
  modality text,
  dicom_file_type text,
  iop text,
  first_ipp text,
  last_ipp text,
  nifti_file_id integer,
  nifti_json_file_id integer,
  nifti_base_file_name text,
  specified_gantry_tilt text,
  computed_gantry_tilt text,
  conversion_time interval
);
create table nifti_conversion_notes(
  nifti_file_from_series_id integer not null,
  note text not null
);
create table nifti_extra_file_from_series(
  nifti_file_from_series_id integer not null,
  nifti_extra_file_id integer not null,
  nifti_extra_file_name text not null
);
create table nifti_dcm2niix_warnings(
  nifti_file_from_series_id integer not null,
  warning text not null
);
