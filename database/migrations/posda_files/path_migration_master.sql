CREATE TABLE if not exists pathology_image_desc (
	file_id int4 not null,
	image_desc text  null
);
CREATE TABLE if not exists pathology_patient_mapping (
	file_id int4 not null unique,
	patient_id text  null,
	original_file_name text NULL,
	collection_name text null,
	site_name text null
);
ALTER TABLE pathology_patient_mapping ADD study_name text NULL;
ALTER TABLE pathology_patient_mapping ADD image_id text NULL;
ALTER TABLE pathology_patient_mapping ADD clinical_trial_subject_id text NULL;

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
	preview_file_id int,
	gammaIndex int);

create table if not exists pathology_visual_review_status (
	path_file_id int4,
	good_status bool,
	reviewing_user text,
	review_time timestamp NULL
);
CREATE table if not exists public.pathology_edit_queue (
	pathology_edit_queue_id serial4 NOT NULL,
	file_id int4 NOT NULL,
	edit_type text NULL,
	edit_details text NULL,
	status text null
);

---is this used?
CREATE TABLE public.pathology_image_description (
	file_id int4 NOT NULL,
	layer_id int4 not null,
	image_desc text NULL
);

CREATE table if not exists public.pathology_path_db_linkage (
	pathology_path_db_linkage_id serial4 NOT NULL,
	file_id int4 NOT NULL,
	node_id text NULL,
	upload_time timestamp null
);

ALTER TABLE pathology_image_description
ADD CONSTRAINT unique_layer_file_id UNIQUE (layer_id, file_id);

alter table pathology_visual_review_files
add column needs_edit bool default null;
