insert into apps (app_name) values ('ActivityBasedCuration');
insert into permissions (app_id, permission_name) values (currval('apps_app_id_seq'), 'launch'), (currval('apps_app_id_seq'), 'debug');
