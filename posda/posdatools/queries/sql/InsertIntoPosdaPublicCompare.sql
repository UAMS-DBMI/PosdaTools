-- Name: InsertIntoPosdaPublicCompare
-- Schema: posda_files
-- Columns: []
-- Args: ['compare_public_to_posda_instance_id', 'sop_instance_uid', 'posda_file_id', 'posda_file_path', 'public_file_path', 'short_report_file_id', 'long_report_file_id']
-- Tags: ['NotInteractive', 'Backlog', 'Transaction', 'public_posda_counts']
-- Description: Lock the file table in posda_files

insert into posda_public_compare(
  compare_public_to_posda_instance_id,
  sop_instance_uid,
  posda_file_id,
  posda_file_path,
  public_file_path,
  short_report_file_id,
  long_report_file_id
) values ( ?, ?, ?, ?, ?, ?, ?)