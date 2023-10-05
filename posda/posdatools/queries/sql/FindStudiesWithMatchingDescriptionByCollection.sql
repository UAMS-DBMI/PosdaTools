-- Name: FindStudiesWithMatchingDescriptionByCollection
-- Schema: posda_files
-- Columns: ['study_instance_uid']
-- Args: ['collection', 'description']
-- Tags: ['by_study', 'consistency']
-- Description: Find Studies by Collection with Null Study Description
-- 

select distinct study_instance_uid from (
  select distinct study_instance_uid, count(*) from (
    select distinct
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
    from
      file_study natural join ctp_file
    where
      project_name = ? and study_description = ?
    group by
      study_instance_uid, study_date, study_time,
      referring_phy_name, study_id, accession_number,
      study_description, phys_of_record, phys_reading,
      admitting_diag
  ) as foo
  group by study_instance_uid
) as foo
where count > 1
