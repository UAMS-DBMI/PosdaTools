/*
	PT-1226
*/
CREATE TABLE grouping (
    grouping_id serial4 NOT NULL PRIMARY KEY,
    grouping_name text NULL,
    grouping_type text NULL, -- DICOM, NIFTI, MIRAX
    grouping_date timestamptz NULL
);

CREATE TABLE file_grouping (
    grouping_id int NOT NULL,
    file_id int NOT NULL,
    PRIMARY KEY (grouping_id, file_id),
    FOREIGN KEY (grouping_id) REFERENCES grouping(grouping_id),
    FOREIGN KEY (file_id) REFERENCES file(file_id)
);
