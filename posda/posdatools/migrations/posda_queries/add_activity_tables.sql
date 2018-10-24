CREATE TABLE activity (
    activity_id serial primary key,
    brief_description text,
    when_created timestamp with time zone,
    who_created text
);

CREATE TABLE activity_inbox_content (
    activity_id integer references activity(activity_id),
    user_inbox_content_id integer references user_inbox_content(user_inbox_content_id)
);

CREATE TABLE activity_posda_file (
    activity_id integer references activity(activity_id),
    file_id_in_posda integer,
    association_description text,
    primary key (activity_id, file_id_in_posda)
);
