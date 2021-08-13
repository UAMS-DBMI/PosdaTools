create table nifti_projection_review(
  nifti_file_id integer not null references file (file_id),
  reviewer text not null,
  review_status text not null,
  review_time timestamptz not null
);
