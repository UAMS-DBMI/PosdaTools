-- Name: AddInsertedToFileCopyFromPublic
-- Schema: posda_files
-- Columns: []
-- Args: ['inserted_file_id', 'copy_from_public_id', 'sop_instance_uid']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

update file_copy_from_public set
  inserted_file_id = ?
where copy_from_public_id = ? and sop_instance_uid = ?