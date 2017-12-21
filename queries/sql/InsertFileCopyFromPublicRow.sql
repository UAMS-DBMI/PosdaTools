-- Name: InsertFileCopyFromPublicRow
-- Schema: posda_files
-- Columns: []
-- Args: ['copy_from_public_id', 'sop_instance_uid', 'replace_file_id', 'copy_file_path']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

insert into file_copy_from_public(
  copy_from_public_id, sop_instance_uid, replace_file_id, copy_file_path
) values (
  ?, ?, ?, ?
)