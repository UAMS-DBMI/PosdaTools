
--
-- Name: pathology_cleanup script
--

alter table pathology_visual_review_files drop column needs_edit;
alter table pathology_visual_review_files rename column svsfile_id to path_file_id;
alter table pathology_visual_review_status rename column svsfile_id to path_file_id;

create table if not exists pathology_visual_review_instance (
	pathology_visual_review_instance_id serial not null,
	activity_creation_id int,
	scheduler text,
	scheduled timestamp);

	create table if not exists pathology_visual_review_files (
	pathology_visual_review_instance_id int,
	path_file_id int,
	preview_file_id int);

create table if not exists pathology_visual_review_status(
	path_file_id int unique,
	good bool);
