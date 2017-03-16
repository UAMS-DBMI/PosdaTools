

CREATE TABLE queries (
    name text PRIMARY KEY,
    query text,
    args text[],
    columns text[],
    tags text[],
    schema text,
    description text
);


CREATE TABLE query_tag_filter (
    filter_name text PRIMARY KEY,
    tags_enabled text[]
);


CREATE TABLE spreadsheet_operation (
    operation_name text NOT NULL PRIMARY KEY,
    command_line text,
    operation_type text,
    input_line_format text,
    tags text[]
);

CREATE TABLE popup_buttons (
    popup_button_id integer NOT NULL,
    name text,
    object_class text,
    btn_col text,
    is_full_table boolean,
    btn_name text
);

CREATE SEQUENCE popup_buttons_popup_button_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
