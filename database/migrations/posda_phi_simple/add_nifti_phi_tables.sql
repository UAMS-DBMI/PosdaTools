-- public.nifti_tag_seen definition

-- Drop table

--DROP TABLE public.nifti_tag_seen;

CREATE TABLE public.nifti_tag_seen (
	nifti_tag_seen_id serial4 NOT NULL,
	tag_name text null,
	CONSTRAINT nifti_tag_seen_tag_key UNIQUE (tag_name)
);

-- public.nifti_value_seen definition

-- Drop table

-- DROP TABLE public.nifti_value_seen;

CREATE TABLE public.nifti_value_seen (
	nifti_value_seen_id serial4 NOT NULL,
	value text NOT NULL,
	CONSTRAINT nifti_value_seen_value_key UNIQUE (value)
);

-- public.nifti_phi_scan_instance definition

-- Drop table

-- DROP TABLE public.nifti_phi_scan_instance;

CREATE TABLE public.nifti_phi_scan_instance (
	nifti_phi_scan_instance_id serial4 NOT NULL,
	description text NOT NULL,
	start_time timestamptz NULL,
	end_time timestamptz NULL
);

-- public.nifti_tag_value_occurrence definition

-- Drop table

--DROP TABLE public.nifti_tag_value_occurrence;

CREATE TABLE public.nifti_tag_value_occurrence (
	nifti_tag_seen_id int4 NOT NULL,
	nifti_value_seen_id int4 NOT NULL,
	nifti_phi_scan_instance_id int4 NOT null,
	file_id int4 not null
);
-- CREATE INDEX nifti_tag_seen_and_nifti_value_seen_index ON public.nifti_tag_value_occurrence USING btree (nifti_tag_seen_id, nifti_value_seen_id);
