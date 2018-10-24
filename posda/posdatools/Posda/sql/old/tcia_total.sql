create table count_report(
  count_report_id serial,
  at timestamp with time zone
);
create table totals_by_collection_site(
  count_report_id integer not null,
  collection_name text,
  site_name text,
  num_subjects integer,
  num_studies integer,
  num_series integer,
  num_sops integer
);
