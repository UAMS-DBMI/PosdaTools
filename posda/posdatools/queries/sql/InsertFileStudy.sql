-- Name: InsertFileStudy
-- Schema: posda_queries
-- Columns: []
-- Args: ['file_id', 'study_instance_uid', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'study_description', 'phys_of_record', 'phys_reading', 'admitting_diag']
-- Tags: ['bills_test', 'posda_db_populate']
-- Description: Add a filter to a tab

insert into file_study(
  file_id, study_instance_uid, study_date,
  study_time, referring_phy_name, study_id,
  accession_number, study_description, phys_of_record,
  phys_reading, admitting_diag
) values (
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?
)