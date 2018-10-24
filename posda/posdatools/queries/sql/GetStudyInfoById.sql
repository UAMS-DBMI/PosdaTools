-- Name: GetStudyInfoById
-- Schema: posda_files
-- Columns: ['file_id', 'study_instance_uid', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'study_description', 'phys_of_record', 'phys_reading', 'phys_reading', 'admitting_diag']
-- Args: ['file_id']
-- Tags: ['reimport_queries']
-- Description: Get file path from id

select
  file_id,
  study_instance_uid,
  study_date,
  study_time,
  referring_phy_name,
  study_id,
  accession_number,
  study_description,
  phys_of_record,
  phys_reading,
  admitting_diag
from file_study
where file_id = ?