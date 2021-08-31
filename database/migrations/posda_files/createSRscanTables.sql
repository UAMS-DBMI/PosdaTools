CREATE TABLE public.sr_phi_scan_instance (
	sr_phi_scan_instance_id serial NOT NULL,
	description text NOT NULL,
	start_time timestamptz NULL,
	end_time timestamptz NULL
);

CREATE TABLE public.sr_path_seen (
	sr_path_seen_id serial NOT NULL,
	path_sig_pattern text NULL,
	tag text NULL
);

CREATE TABLE public.sr_path_value_occurance (
	sr_path_seen_id int4 NOT NULL,
	value_seen_id int4 NOT NULL,
	sr_series_scan_instance_id text NOT NULL,
	sr_phi_scan_instance_id int4 NOT NULL
);

CREATE INDEX sr_path_seen_and_value_seen_index ON public.sr_path_value_occurance USING btree (sr_path_seen_id, value_seen_id);
