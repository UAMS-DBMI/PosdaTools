-- Name: GetDifferencesFromPublicPosdaComparison
-- Schema: posda_files
-- Columns: ['study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'sop_instance_uid', 'posda_file_id', 'posda_file_path', 'public_file_path', 'short_report_file_id', 'long_report_file_id']
-- Args: ['compare_public_to_posda_instance_id']
-- Tags: ['activity_timepoint_support']
-- Description: List of Sops with differences from compare sops public to posda

select distinct
  study_instance_uid, study_date, study_description,
  series_instance_uid, 
  sop_instance_uid, posda_file_id,
  posda_file_path, public_file_path, short_report_file_id,
  long_report_file_id
from
  public_to_posda_file_comparison natural join 
  file_sop_common natural join
  file_series natural join
  file_study natural join ctp_file
where
  compare_public_to_posda_instance_id = ? and visibility is null
order by study_instance_uid, series_instance_uid
