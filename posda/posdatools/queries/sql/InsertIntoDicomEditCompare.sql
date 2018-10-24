-- Name: InsertIntoDicomEditCompare
-- Schema: posda_files
-- Columns: []
-- Args: ['edit_command_file_id', 'from_file_digest', 'to_file_digest', 'short_report_file_id', 'long_report_file_id']
-- Tags: ['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda']
-- Description: Lock the file table in posda_files

insert into dicom_edit_compare(
  edit_command_file_id,
  from_file_digest,
  to_file_digest,
  short_report_file_id,
  long_report_file_id
) values ( ?, ?, ?, ?, ?)