alter table patient_mapping ADD	CONSTRAINT patient_mapping_pk UNIQUE (from_patient_id,to_patient_id);
