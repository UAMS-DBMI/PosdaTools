-- 
-- Copyright 2010, Bill Bennett
--  Part of the Posda package
--  Posda may be copied only under the terms of either the Artistic License or the
--  GNU General Public License, which may be found in the Posda Distribution,
--  or at http://posda.com/License.html
-- 

insert into attr_checkbox(
  attr_name, attr_value, prompt
) values (
  'app', 'Greeting', 'Applications'
);
insert into attr_checkbox(
  attr_name, attr_value, prompt
) values (
  'app', 'LoginMgr', 'Applications'
);
insert into attr_checkbox(
  attr_name, attr_value, prompt
) values (
  'Capabilities', 'CanDebug', 'Capabilities'
);


insert into attr_property_checkbox(
  attr_name, attr_value, property_name, prompt, property_value
) values (
  'app', 'LoginMgr', 'option', 'LoginMgr Options', 'ChangePassword'
);
insert into attr_property_checkbox(
  attr_name, attr_value, property_name, prompt, property_value
) values (
  'app', 'LoginMgr', 'option', 'LoginMgr Options', 'CreateNewUser'
);
insert into attr_property_checkbox(
  attr_name, attr_value, property_name, prompt, property_value
) values (
  'app', 'LoginMgr', 'option', 'LoginMgr Options', 'EditUsers'
);

insert into users(
  user_id, real_name, email_addr, is_super, enc_passwd
) values (
  'admin', '<your_name_here>', '<your_email_here>', true, 'Sw9SzLHLxJ03k'
);
insert into user_attributes(
  user_id, attr_name, attr_value
) values (
  'admin', 'app', 'Greeting'
);
insert into user_attributes(
  user_id, attr_name, attr_value
) values (
  'admin', 'app', 'LoginMgr'
);
insert into user_attributes(
  user_id, attr_name, attr_value
) values (
  'admin', 'capability', 'CanDebug'
);
insert into user_attr_property(
  user_id, attr_name, attr_value, property_name, property_value
) values (
  'admin', 'app', 'LoginMgr', 'option', 'ChangePassword'
);
insert into user_attr_property(
  user_id, attr_name, attr_value, property_name, property_value
) values (
  'admin', 'app', 'LoginMgr', 'option', 'CreateNewUser'
);
insert into user_attr_property(
  user_id, attr_name, attr_value, property_name, property_value
) values (
  'admin', 'app', 'LoginMgr', 'option', 'EditUsers'
);
