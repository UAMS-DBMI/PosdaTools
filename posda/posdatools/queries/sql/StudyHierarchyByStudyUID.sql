-- Name: StudyHierarchyByStudyUID
-- Schema: posda_files
-- Columns: ['study_instance_uid', 'study_description', 'series_instance_uid', 'series_description', 'modality', 'number_of_sops']
-- Args: ['study_instance_uid']
-- Tags: ['by_study', 'Hierarchy']
-- Description: Show List of Study Descriptions, Series UID, Series Descriptions, and Count of SOPS for a given Study Instance UID

select distinct
  study_instance_uid, study_description,
  series_instance_uid, series_description,
  modality,
  count(distinct sop_instance_uid) as number_of_sops
from
  file_study natural join ctp_file natural join file_series natural join file_sop_common
where study_instance_uid = ? and visibility is null
group by
  study_instance_uid, study_description,
  series_instance_uid, series_description, modality