create table for_nickname (
  project_name text,
  site_name text,
  subj_id text,
  for_nickname text,
  for_instance_uid text
);
create unique index for_nickname_lookup on
  for_nickname(project_name, site_name, subj_id, for_nickname);
create unique index for_nickname_lookup_by_uid on
  for_nickname(project_name, site_name, subj_id, for_instance_uid);
