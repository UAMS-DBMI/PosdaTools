-- Name: InsertIntoPosdaPublicCompare
-- Schema: posda_files
-- Columns: []
-- Args: ['background_subprocess_id', 'sop_instance_uid', 'from_file_id', 'short_report_file_id', 'long_report_file_id', 'to_file_path']
-- Tags: ['NotInteractive', 'Backlog', 'Transaction', 'public_posda_counts']
-- Description: Lock the file table in posda_files

insert into posda_public_compare(
  background_subprocess_id,
  sop_instance_uid,
  from_file_id,
  short_report_file_id,
  long_report_file_id,
  to_file_path
) values ( ?, ?, ?, ?, ?, ?)