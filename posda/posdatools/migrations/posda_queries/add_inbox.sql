drop table if exists user_inbox_content_operation;
drop table if exists user_inbox_content;
drop table if exists user_inbox;

create table user_inbox (
  user_inbox_id serial primary key,
  user_name text unique,
  user_email_addr text
);

create table user_inbox_content (
  user_inbox_content_id serial primary key,
  user_inbox_id integer references user_inbox(user_inbox_id),
  background_subprocess_report_id integer references background_subprocess_report (background_subprocess_report_id),
  current_status text,
  statuts_note text,
  date_entered timestamp,
  date_dismissed timestamp
);

create table user_inbox_content_operation (
  user_inbox_content_id integer references user_inbox_content(user_inbox_content_id),
  operation_type text,
  when_occurred timestamp,
  how_invoked text,
  invoking_user text
);
