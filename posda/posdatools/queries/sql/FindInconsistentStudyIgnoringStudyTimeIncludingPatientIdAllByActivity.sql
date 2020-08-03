-- Name: FindInconsistentStudyIgnoringStudyTimeIncludingPatientIdAllByActivity
-- Schema: posda_files
-- Columns: ['study_instance_uid']
-- Args: ['activity_id']
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
    where
      file_id in (
        select file_id
        from activity_timepoint_file
        where activity_timepoint_id = (
           select max(activity_timepoint_id) as activity_timepoint_id
           from activity_timepoint
           where activity_id = ?
        )
      )
    group by
      patient_id, study_instance_uid, study_date,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
