alter table image_equivalence_class 
  add column hidden bool not null default false;

create table log_iec_hide (
  user_name text,
  project text not null,
  site text not null,
  patient text,
  hidden boolean,
  date timestamp not null default now()
);
