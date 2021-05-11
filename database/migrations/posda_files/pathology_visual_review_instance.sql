
--
-- Name: pathology_visual_review_instance
--

create table pathology_visual_review_instance (
	pathology_visual_review_instance_id serial not null,
	activity_creation_id int,
	scheduler text,
	scheduled timestamp

);
