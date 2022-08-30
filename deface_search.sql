create table series(
  series_id serial,
  series_instance_uid text not null,
  study_instance_uid text not null,
  collection text,
  site text
);
create table file_in_series(
  file_in_series_id serial,
  series_id integer not null,
  frame_of_reference_uid text;
  sop_instance_uid text not null,
  file_path text not null,
  num_slices integer not null,
  digest not null
);
create table image_slice(
  slice_id serial,
  file_in_series_id integer not null,
  offset_within_file integer not null,
  bytes_in_slice integer not null
);
create table slice_geometry(
  slice_id integer not null,
  ipp_x float,
  ipp_y float,
  ipp_z float,
  unique_iop_id integer,
  rows integer,
  cols integer,
  pixel_spacing_row float,
  pixel_spacing_col float
);
create table unique_iop(
  unique_iop_id serial,
  row_dir_x float,
  row_dir_y float,
  row_dir_z float,
  col_dir_x float,
  col_dir_y float,
  col_dir_z float
);
create table slice_pixel_interpretation(
  slice_id integer not null,
  bits_allocated integer not null,
  bits_stored integer not null,
  high_bit integer not null,
  samples_per_pixel integer,
  pixel_padding_value integer,
  is_signed boolean,
  low_is_white boolean,
  slope float,
  intercept float,
  modality text
);
create table series_volume(
  series_id integer not null,
  volume_number integer not null,
  volume_type text, // type: rrpp, orpp, cyl, irreg, scap
  //type rrpp,oroo
  first_voxel_x float,
  first_voxel_y float,
  first_voxel_z float,
  unique_iop_id integer,
  // type oroo, cyl
  axis_dir_x float,
  axis_dir_y float,
  axis_dir_z float,
  // type cyl
  rotation_type text, // type: col, row
  top_cyl_x float,
  top_cyl_y float,
  top_cyl_z float
);
create table series_volume_slice(
  series_volume_id integer not null,
  slice_id integer not null,
  slice_index integer not null
);
