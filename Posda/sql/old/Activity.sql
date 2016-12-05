create table ControllerMeasurements(
  time_of_measurement timestamp with time zone,
  directories_in_receiver integer,
  active_connections integer,
  files_waiting_in_db integer,
  total_files_id_db integer,
  total_apps_running integer,
  queued_sends integer,
  queued_subprocess integer,
  running_discard integer,
  running_sends integer,
  running_subprocess integer,
  locked_directories integer,
  connection_count integer
);
create table ControllerRestarts(
  time_of_controller_start timestamp with time zone
);
create table ControllerLogins(
  time_of_controller_login timestamp with time zone,
  controller_user text
);
create table ControllerAppInvocation(
  app_instance_id serial,
  app_session_id text,
  app_server_port integer,
  app_pid integer,
  time_of_app_select timestamp with time zone,
  time_of_app_quit timestamp with time zone,
  app_selected text,
  controller_user text,
  stderr_lines integer,
  stdout_lines integer
);
