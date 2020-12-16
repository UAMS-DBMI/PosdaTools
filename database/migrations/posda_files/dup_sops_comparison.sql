create table dup_sops_comparison(
  subprocess_invocation_id integer not null,
  sop_index integer not null,
  cmp_index integer not null,
  from_file_id integer not null,
  to_file_id integer not null,
  long_report_file_id integer,
  equiv_class text
);
