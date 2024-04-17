CREATE TABLE public.pathology_edit_queue (
	pathology_edit_queue_id serial4 NOT NULL,
	file_id int4 NOT NULL,
	edit_type text NULL,
	edit_details text NULL,
	status text null
);

alter table pathology_visual_review_preview_files
add column gammaIndex int;
