-- Name: InsertEditEventRow
-- Schema: posda_files
-- Columns: []
-- Args: ['edit_desc_file', 'edit_comment', 'num_files', 'process_id']
-- Tags: ['Insert', 'NotInteractive', 'used_in_import_edited_files']
-- Description: Insert edit_event
-- For use in scripts
-- Not really intended for interactive use
-- 

insert into dicom_edit_event(
  edit_desc_file, time_started, edit_comment, num_files, process_id, edits_done
) values (?, now(), ?, ?, ?, 0)
