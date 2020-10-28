create table seg_bitmap_file(
  seg_bitmap_file_id integer not null unique,
  number_segmentations integer not null,
  num_slices integer not null,
  rows integer not null,
  cols integer not null,
  frame_of_reference_uid text not null,
  patient_id text not null,
  study_instance_uid text not null,
  series_instance_uid text not null,
  sop_instance_uid text not null,
  pixel_offset integer not null
);
create table seg_slice_bitmap_file (
  seg_slice_bitmap_file_id integer not null,
  seg_bitmap_slice_no integer not null,
  seg_bitmap_file_id integer not null,
  segmentation_number integer not null,
  iop text not null,
  ipp text not null,
  total_one_bits integer not null,
  num_bare_points integer not null
);
create table seg_slice_bitmap_file_related_image(
  seg_bitmap_file_id integer not null,
  seg_bitmap_slice_no integer not null,
  sop_instance_uid text not null
);
create table seg_slice_bitmap_bare_point(
  seg_bitmap_file_id integer not null,
  seg_bitmap_slice_no integer not null,
  point text not null
);
create table seg_bitmap_related_sops(
  seg_bitmap_file_id integer not null,
  series_instance_uid text,
  sop_instance_uid text
);
create table seg_bitmap_segmentation(
  seg_bitmap_file_id integer not null,
  segmentation_num integer,
  label text,
  description text,
  color text,
  algorithm_type text,
  algorithm_name text,
  segmented_category text,
  segmented_type text
);

