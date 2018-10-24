create table series_projection (
  series_instance_uid text primary key,
  date timestamp,
  who text,
  needs_closer_inspection boolean
);
