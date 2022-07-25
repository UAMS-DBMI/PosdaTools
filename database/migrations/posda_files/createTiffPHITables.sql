-- public.tiff_tag_seen definition

-- Drop table

--DROP TABLE public.tiff_tag_seen;

CREATE TABLE public.tiff_tag_seen (
	tiff_tag_seen_id serial4 NOT NULL,
	is_private bool NULL,
	tag_name text null,
	CONSTRAINT tiff_tag_seen_tag_key UNIQUE (tag_name)
);

-- public.tiff_value_seen definition

-- Drop table

-- DROP TABLE public.tiff_value_seen;

CREATE TABLE public.tiff_value_seen (
	tiff_value_seen_id serial4 NOT NULL,
	value text NOT NULL,
	CONSTRAINT tiff_value_seen_value_key UNIQUE (value)
);

-- public.tiff_phi_scan_instance definition

-- Drop table

-- DROP TABLE public.tiff_phi_scan_instance;

CREATE TABLE public.tiff_phi_scan_instance (
	tiff_phi_scan_instance_id serial4 NOT NULL,
	description text NOT NULL,
	start_time timestamptz NULL,
	end_time timestamptz NULL
);

-- public.tiff_tag_value_occurance definition

-- Drop table

--DROP TABLE public.tiff_tag_value_occurrence;

CREATE TABLE public.tiff_tag_value_occurrence (
	tiff_tag_seen_id int4 NOT NULL,
	tiff_value_seen_id int4 NOT NULL,
	tiff_phi_scan_instance_id int4 NOT null,
	file_id int4 not null
);
-- CREATE INDEX tiff_tag_seen_and_tiff_value_seen_index ON public.tiff_tag_value_occurrence USING btree (tiff_tag_seen_id, tiff_value_seen_id);
