delete from user_app_permissions;
delete from users;
delete from apps;
delete from permissions;

-- Default apps
-- TODO: This could be broken up into a file for each app, and live
--       in the app's directory.
insert into apps (app_name) values ('UserAdmin');
insert into apps (app_name) values ('PosdaCuration');
insert into apps (app_name) values ('PhiFixer');
insert into apps (app_name) values ('ReviewPhi');
insert into apps (app_name) values ('SubmissionSender');
insert into apps (app_name) values ('CountGetter');
insert into apps (app_name) values ('FileDist');
insert into apps (app_name) values ('DicomProxy');
insert into apps (app_name) values ('DicomProxyAnalysis');
insert into apps (app_name) values ('DbIf');


-- Default users
insert into users (user_name, full_name, password) values (
  'admin', 'Default Admin Account', 'aJE5lY8D,2wUueoiymAn8HsfbdAp0kPfTiODV7kpeNUttYTgQGbE');


-- Default permissions
insert into permissions (permission_name) values ('debug');
insert into permissions (permission_name) values ('launch');


-- Default user/app/permission associations
insert into user_app_permissions values (
  (select user_id from users where user_name = 'admin'),
  (select app_id from apps where app_name = 'UserAdmin'),
  (select permission_id from permissions where permission_name = 'launch')
);
insert into user_app_permissions values (
  (select user_id from users where user_name = 'admin'),
  (select app_id from apps where app_name = 'UserAdmin'),
  (select permission_id from permissions where permission_name = 'debug')
);



-- PURE TESTING DATA DO NOT PUT IN PRODUCTION
insert into users (user_name, full_name) values ('quasar', 
                                                'Quasar Jarosz');
insert into user_app_permissions values (2, 1, 1);


insert into user_app_permissions values (
  (select user_id from users where user_name = 'quasar'),
  (select app_id from apps where app_name = 'PosdaCuration'),
  (select permission_id from permissions where permission_name = 'launch')
);
insert into user_app_permissions values (
  (select user_id from users where user_name = 'quasar'),
  (select app_id from apps where app_name = 'PosdaCuration'),
  (select permission_id from permissions where permission_name = 'debug')
);

insert into user_app_permissions values (
  (select user_id from users where user_name = 'quasar'),
  (select app_id from apps where app_name = 'PhiFixer'),
  (select permission_id from permissions where permission_name = 'launch')
);
insert into user_app_permissions values (
  (select user_id from users where user_name = 'quasar'),
  (select app_id from apps where app_name = 'PhiFixer'),
  (select permission_id from permissions where permission_name = 'debug')
);


select *
from user_app_permissions
natural join users
natural join apps
natural join permissions;
