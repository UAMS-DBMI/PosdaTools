-- Name: ImportIntoFileStudy
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'study_instance_uid', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'study_description', 'phys_of_record', 'phys_reading', 'admitting_diag']
-- Tags: ['reimport_queries']
-- Description: Get file path from id

insert into file_study
  (file_id, study_instance_uid, study_date,
   study_time, referring_phy_name, study_id,
   accession_number, study_description, phys_of_record,
   phys_reading, admitting_diag)
values
  (?, ?, ?,
   ?, ?, ?,
   ?, ?, ?,
   ?, ?)
