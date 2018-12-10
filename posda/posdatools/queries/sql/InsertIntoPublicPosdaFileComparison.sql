-- Name: InsertIntoPublicPosdaFileComparison
-- Schema: posda_files
-- Columns: []
-- Args: ['compare_public_to_posda_instance_id', 'sop_instance_uid', 'posda_file_id', 'posda_file_path', 'public_file_path', 'short_report_file_id', 'long_report_file_id']
-- Tags: ['activity_timepoint_support']
-- Description: Insert a column into public_to_posda_file_comparison

insert into public_to_posda_file_comparison(
  compare_public_to_posda_instance_id,
  sop_instance_uid,
  posda_file_id,
  posda_file_path,
  public_file_path,
  short_report_file_id,
  long_report_file_id   
)values(
  ?, ?, ?, ?,
  ?, ?, ?
)
