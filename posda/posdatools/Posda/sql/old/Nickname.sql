create table study_nickname (
  project_name text,
  site_name text,
  subj_id text,
  study_nickname text,
  study_instance_uid text
);
create unique index study_nickname_lookup on
  study_nickname(project_name, site_name, subj_id, study_nickname);
create unique index study_nickname_lookup_by_uid on
  study_nickname(project_name, site_name, subj_id, study_instance_uid);

create table series_nickname (
  project_name text,
  site_name text,
  subj_id text,
  series_nickname text,
  series_instance_uid text
);
create unique index series_nickname_lookup on
  series_nickname(project_name, site_name, subj_id, series_nickname);
create unique index series_nickname_lookup_by_uid on
  series_nickname(project_name, site_name, subj_id, series_instance_uid);

create table sop_nickname (
  project_name text,
  site_name text,
  subj_id text,
  sop_nickname text,
  modality text,
  has_modality_conflict boolean,
  sop_instance_uid text
);
create unique index sop_nickname_lookup on
  sop_nickname(project_name, site_name, subj_id, sop_nickname);
create unique index sop_nickname_lookup_by_uid on
  sop_nickname(project_name, site_name, subj_id, sop_instance_uid);

create table file_nickname (
  project_name text,
  site_name text,
  subj_id text,
  sop_instance_uid text,
  sop_nickname_copy text,
  version_number integer,
  file_digest text unique
);
create index file_nickname_lookup on
  file_nickname(project_name, site_name, subj_id, sop_instance_uid);

create table nickname_sequence (
  project_name text,
  site_name text,
  subj_id text,
  nickname_type text,
  next_value integer
);
