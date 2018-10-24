create table background_buttons (
  background_button_id serial primary key,
  operation_name text,
  object_class text,
  button_text text,
  tags text[]
);
