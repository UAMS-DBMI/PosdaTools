
--
-- Name: pathology_cleanup script
--

drop table pathology_visual_review_instance
drop table pathology_visual_review_files
drop table pathology_visual_review_status

create table if not exists pathology_visual_review_instance (
	pathology_visual_review_instance_id serial not null,
	activity_creation_id int,
	scheduler text,
	scheduled timestamp);

create table if not exists pathology_visual_review_files (
	pathology_visual_review_instance_id int not null,
	path_file_id int not null unique);

create table if not exists pathology_visual_review_preview_files (
	path_file_id int,
	preview_file_id int);

create table if not exists pathology_visual_review_status (
	path_file_id int4,
	good_status bool,
	reviewing_user text,
	review_time timestamp NULL
);
