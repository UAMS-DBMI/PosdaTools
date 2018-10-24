create table equipment_signature (
  equipment_signature_id serial NOT NULL,
  equipment_signature text NOT NULL
);
create unique index equipment_index on equipment_signature(signature);
create table scan_event(
  scan_event_id serial NOT NULL,
  scan_started timestamp with time zone,
  scan_ended timestamp with time zone,
  scan_status text,
  scan_description text,
  num_series_to_scan integer,
  num_series_scanned integer
);
create table series_scan (
  series_scan_id serial NOT NULL,
  scan_event_id integer  NOT NULL,
  equipment_signature_id integer NOT NULL,
  series_instance_uid text NOT NULL,
  series_scanned_file text,
  series_scan_status text
);
create unique index series_index 
  on series_scan(series_instance_uid,scan_event_id);
create table seen_value (
  seen_value_id serial NOT NULL,
  value text
);
create unique index value_index on seen_value(value);
create table element_signature(
  element_signature_id serial NOT NULL,
  element_signature text NOT NULL,
  is_private boolean NOT NULL,
  vr text NOT NULL
);
create unique index ele_signature_index
   on element_signature(element_signature, vr);

create table scan_element(
  scan_element_id serial NOT NULL,
  element_signature_id integer NOT NULL,
  series_scan_id integer NOT NULL,
  seen_value_id integer NOT NULL
);
create table sequence_index (
  scan_element_id integer NOT NULL,
  sequence_level integer NOT NULL,
  item_number integer NOT NULL
);
