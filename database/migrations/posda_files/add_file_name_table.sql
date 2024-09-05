/*
	PT-1179
*/
CREATE TABLE file_name (
    file_id int4 NOT NULL,
    file_name_text text NULL,
    PRIMARY KEY (file_id),
    FOREIGN KEY (file_id) REFERENCES file(file_id)
);