-- Name: StudyConsistencyWithPatientId
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'count', 'study_description', 'study_date', 'study_time', 'referring_phy_name', 'study_id', 'accession_number', 'phys_of_record', 'phys_reading', 'admitting_diag']
-- Args: ['study_instance_uid']
-- Tags: ['by_study', 'consistency', 'study_consistency']
-- Description: Check a Study for Consistency
-- 

select distinct
  patient_id, study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag, count(distinct file_id)
from
  file_study natural join file_patient natural join ctp_file
where study_instance_uid = ? and visibility is null
group by
  patient_id, study_instance_uid, study_date, study_time,
  referring_phy_name, study_id, accession_number,
  study_description, phys_of_record, phys_reading,
  admitting_diag
