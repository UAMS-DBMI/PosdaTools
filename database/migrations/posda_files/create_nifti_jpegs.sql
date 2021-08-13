create table nifti_jpeg_slice(
  nifti_file_id integer not null references file (file_id),
  vol_num integer not null,
  slice_number integer not null,
  flipped boolean not null,
  jpeg_file_id integer not null references file (file_id),
  UNIQUE(nifti_file_id, vol_num, slice_number, flipped, jpeg_file_id)
);
create table nifti_jpeg_vol_projection(
  nifti_file_id integer not null references file (file_id),
  vol_num integer not null,
  proj_type text not null,
  jpeg_file_id integer not null references file (file_id),
  UNIQUE(nifti_file_id, vol_num, proj_type, jpeg_file_id)
);
create table nifti_jpeg_projection(
  nifti_file_id integer not null references file (file_id),
  proj_type text not null,
  jpeg_file_id integer not null references file (file_id),
  UNIQUE(nifti_file_id, proj_type, jpeg_file_id)
);
