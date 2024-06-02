CREATE TABLE public.pathology_image_description (
	file_id int4 NOT NULL,
	layer_id int4 not null,
	image_desc text NULL
);

ALTER TABLE pathology_image_description
ADD CONSTRAINT unique_layer_file_id UNIQUE (layer_id, file_id);
