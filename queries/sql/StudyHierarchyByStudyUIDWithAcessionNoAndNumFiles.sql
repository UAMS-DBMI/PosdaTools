-- Name: StudyHierarchyByStudyUIDWithAcessionNoAndNumFiles
-- Schema: posda_files
-- Columns: ['study_instance_uid', 'study_description', 'series_instance_uid', 'series_description', 'modality', 'accession_number', 'num_files']
-- Args: ['study_instance_uid']
-- Tags: ['by_study', 'Hierarchy']
-- Description: Show List of Study Descriptions, Series UID, Series Descriptions, and Count of SOPS for a given Study Instance UID

select distinct
  study_instance_uid, study_description,
  series_instance_uid, series_description,
  modality,
  '<' || accession_number || '>' as accession_number,
  count(distinct sop_instance_uid) as num_files
from
  file_study natural join ctp_file natural join file_series natural join file_sop_common
where study_instance_uid = ? and visibility is null
group by
  study_instance_uid, study_description,
  series_instance_uid, series_description, modality,accession_number
order by accession_number