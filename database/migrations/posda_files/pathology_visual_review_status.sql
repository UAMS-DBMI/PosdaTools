
--
-- Name: pathology_visual_review_status
--

create table pathology_visual_review_status(
	path_file_id int unique,
	good bool
);
