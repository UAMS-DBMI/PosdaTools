create table request(
  request_id serial,
  submitter_id integer not null,
  received_file_path text,
  copied_file_path text,
  file_copied boolean,
  copy_error boolean,
  copy_path text,
  file_digest text,
  file_in_posda boolean,
  import_error boolean,
  time_received timestamp,
  time_copied timestamp,
  time_entered timestamp
);
create index request_lookup on 
  request(submitter_id, file_in_posda, file_copied, copy_error, import_error);
create table submitter(
  submitter_id serial,
  collection text not null,
  site text not null,
  subj text not null,
  priority integer
);
create unique index submitter_lookup on submitter(collection, site, subj);
create table request_error(
  request_id integer not null,
  error_time timestamp,
  error_description text
);
create table control_status(
  status text not null,
  processor_pid text,
  idle_poll_interval interval,
  last_service timestamp,
  pending_change_request text,
  source_pending_change_request text,
  request_time timestamp
);
