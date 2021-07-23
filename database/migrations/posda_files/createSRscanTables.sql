CREATE TABLE public.sr_phi_scan_instance (
	sr_phi_scan_instance_id serial NOT NULL,
	description text NOT NULL,
	start_time timestamptz NULL,
	end_time timestamptz NULL
);



CREATE TABLE public.sr_file_scan_instance (
	sr_file_scan_instance_id serial NOT NULL,
	sr_phi_scan_instance_id int4 NOT NULL,
	sop_instance_uid int4 NULL,
	start_time timestamptz NULL,
	end_time timestamptz NULL
);



CREATE TABLE public.sr_path_seen (
	sr_path_seen_id serial NOT NULL,
	path_sig_pattern text NULL,
	vr text NULL,
	is_private bool NULL,
	tag_name text NULL,
	private_disposition text NULL
);
CREATE UNIQUE INDEX sr_path_seen_vr_pair_index ON public.sr_path_seen USING btree (path_sig_pattern, vr);

CREATE TABLE public.sr_path_value_occurance (
	sr_path_seen_id int4 NOT NULL,
	value_seen_id int4 NOT NULL,
	sr_file_scan_instance_id int4 NOT NULL,
	sr_phi_scan_instance_id int4 NOT NULL
);
CREATE INDEX sr_path_seen_and_value_seen_index ON public.sr_path_value_occurance USING btree (sr_path_seen_id, value_seen_id);
