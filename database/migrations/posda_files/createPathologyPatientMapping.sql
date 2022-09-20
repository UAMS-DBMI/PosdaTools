-- pathology_patient_mapping definition

-- Drop table

--DROP TABLE pathology_patient_mapping;

CREATE TABLE pathology_patient_mapping (
	file_id int4 not null unique,
	patient_id text  null,
	original_file_name text NULL,
	collection_name text null,
	site_name text null
);
