
--
-- Name: add_nifti_visual_review script
--

-- drop table nifti_visual_review_instance;
-- drop table nifti_visual_review_files;
-- drop table nifti_visual_review_status;

create table if not exists nifti_visual_review_instance (
	nifti_visual_review_instance_id serial not null,
	activity_creation_id int,
	scheduler text,
	scheduled timestamp);

create table if not exists nifti_visual_review_files (
	nifti_visual_review_instance_id int not null,
	nifti_file_id int not null unique);

create table if not exists nifti_visual_review_status (
	nifti_file_id int4,
	good_status bool,
	reviewing_user text,
	review_time timestamp NULL
);
