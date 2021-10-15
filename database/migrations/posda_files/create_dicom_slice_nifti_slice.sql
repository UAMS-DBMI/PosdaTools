create table dicom_slice_nifti_slice(
  dicom_file_id integer not null references file(file_id),
  nifti_file_id integer not null references file(file_id),
  dicom_frame_number integer,
  nifti_slice_number integer not null,
  nifti_volume_number integer not null,
  pixel_data_digest text,
  comment text
);

create table defaced_dicom_series(
  subprocess_invocation_id integer not null,
  undefaced_nifti_file integer not null,
  defaced_nifti_file integer not null,
  original_dicom_series_instance_uid text not null,
  defaced_dicom_series_instance_uid text not null,
  number_of_files integer not null,
  import_event_comment text not null,
  difference_nifti_file integer
);
