

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
