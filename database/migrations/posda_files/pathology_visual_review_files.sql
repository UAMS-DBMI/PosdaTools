
--
-- Name: pathology_visual_review_files
--

create table pathology_visual_review_files (
	pathology_visual_review_instance_id int,
	svsfile_id int,
	preview_file_id int,
	needs_edit bool NULL
);
