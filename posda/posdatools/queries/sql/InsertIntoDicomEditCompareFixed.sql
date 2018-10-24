-- Name: InsertIntoDicomEditCompareFixed
-- Schema: posda_files
-- Columns: []
-- Args: ['subprocess_invocation_id', 'from_file_digest', 'to_file_digest', 'short_report_file_id', 'long_report_file_id', 'to_file_path']
-- Tags: ['NotInteractive', 'Backlog', 'Transaction', 'used_in_file_import_into_posda', 'public_posda_counts']
-- Description: Lock the file table in posda_files

insert into dicom_edit_compare(
  subprocess_invocation_id,
  from_file_digest,
  to_file_digest,
  short_report_file_id,
  long_report_file_id,
  to_file_path
) values ( ?, ?, ?, ?, ?, ?)