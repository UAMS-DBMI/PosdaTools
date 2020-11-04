create table seg_slice_to_contour(
seg_slice_bitmap_file_id integer not null,
rows integer not null,
cols integer not null,
num_contours integer not null,
num_points integer not null,
contour_slice_file_id integer not null
);
