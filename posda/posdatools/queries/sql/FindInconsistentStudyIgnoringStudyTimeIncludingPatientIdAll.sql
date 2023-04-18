-- Name: FindInconsistentStudyIgnoringStudyTimeIncludingPatientIdAll
-- Schema: posda_files
-- Columns: ['study_instance_uid']
-- Args: []
-- Tags: ['by_study', 'consistency', 'study_consistency']
-- Description: Find Inconsistent Studies
-- 

select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      patient_id, study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join file_patient natural join ctp_file
    group by
      patient_id, study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
