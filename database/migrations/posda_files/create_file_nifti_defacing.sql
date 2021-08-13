create table file_nifti_defacing (
	file_nifti_defacing_id serial primary key,
	from_nifti_file integer not null references file (file_id),
	to_nifti_file integer references file (file_id),
	three_d_rendered_face integer references file (file_id),
	three_d_rendered_face_box integer references file (file_id),
	three_d_rendered_defaced integer references file (file_id),
	completed_time timestamp with time zone,
	comments text
);
