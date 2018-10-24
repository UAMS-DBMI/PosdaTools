alter table background_subprocess add primary key (background_subprocess_id);

create table background_subprocess_report (
  background_subprocess_report_id serial primary key,
  background_subprocess_id integer references background_subprocess(background_subprocess_id),
  file_id integer not null,
  name text not null,
  constraint background_subprocess_report_uniq unique (background_subprocess_id, file_id)
);
