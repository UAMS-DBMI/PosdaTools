create table users (
    user_id serial primary key,
    user_name text unique not null,
    full_name text not null,
    password text
);

create table apps (
    app_id serial primary key,
    app_name text not null
);
create table permissions (
    permission_id serial primary key,
    permission_name text not null
);

create table user_app_permissions (
    user_id integer references users on delete cascade,
    app_id integer references apps on delete cascade,
    permission_id integer references permissions on delete cascade
);

