ALTER TABLE patient_mapping ADD COLUMN upload_id int4;
ALTER TABLE patient_mapping ADD COLUMN active bool;
ALTER TABLE patient_mapping ADD COLUMN patient_mapping_id SERIAL4 PRIMARY KEY;

update patient_mapping pm set upload_id = 0;
update patient_mapping pm set active = true;
