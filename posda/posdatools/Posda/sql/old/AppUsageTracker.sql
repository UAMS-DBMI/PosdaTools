create table app_instance(
  app_instance_id serial,
  started_at timestamp with time zone,
  pid integer
);
create table app_measurement(
  app_instance_id integer not null,
  at timestamp with time zone,
  pcpu float,
  sz integer,
  vsz bigint,
  num_rcv_sessions integer,
  num_running_apps integer,
  files_in_db_backlog integer,
  dirs_in_receive_backlog integer,
  running_edits_extracts integer,
  queued_edits_extracts integer,
  running_sends integer,
  queued_sends integer,
  running_discards integer,
  num_locks integer,
  num_sessions integer,
  total_transactions integer,
  avg_import_time integer
);
