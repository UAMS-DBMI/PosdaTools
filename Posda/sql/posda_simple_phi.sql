create table element_seen(
  element_seen_id serial,
  element_sig_pattern text,
  vr text
);
create unique index element_seen_vr_pair_index
  on element_seen(element_sig_pattern, vr);
create table value_seen(
  value_seen_id serial,
  value text not null unique
);
create table element_value_occurance(
  element_seen_id integer not null,
  value_seen_id integer not null,
  series_scan_instance_id integer not null,
  phi_scan_instance_id integer not null
);
create table series_scan_instance(
  series_scan_instance_id serial,
  scan_instance_id integer not null,
  series_instance_uid text not null,
  num_files integer,
  start_time timestamp with time zone,
  end_time timestamp with time zone
);
create table phi_scan_instance(
  phi_scan_instance_id serial,
  description text not null,
  start_time timestamp with time zone,
  num_series integer,
  num_series_scanned integer,
  end_time timestamp with time zone
);
