-- Name: IncrementEditsDone
-- Schema: posda_files
-- Columns: []
-- Args: ['dicom_edit_event_id']
-- Tags: ['Insert', 'NotInteractive', 'used_in_import_edited_files']
-- Description: Increment edits done in dicom_edit_event table
-- For use in scripts
-- Not really intended for interactive use
-- 

update dicom_edit_event
  set edits_done = edits_done + 1
where
  dicom_edit_event_id = ?