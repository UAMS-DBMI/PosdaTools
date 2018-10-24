-- Name: FindFilesInStudyWithDescriptionByStudyUID
-- Schema: posda_files
-- Columns: ['study_instance_uid', 'count', 'study_description', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'phys_of_record', 'phys_reading', 'admitting_diag']
-- Args: ['study_instance_uid']
-- Tags: ['by_study', 'consistency']
-- Description: Find SopInstanceUID and Description for All Files In Study
-- 

select distinct
  study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag, count(*)
from
  file_study natural join ctp_file
where study_instance_uid = ? and visibility is null
group by
  study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag
