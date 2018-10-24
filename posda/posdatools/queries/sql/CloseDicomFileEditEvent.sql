-- Name: CloseDicomFileEditEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['report_file_id', 'notify', 'dicom_edit_event_id']
-- Tags: ['Insert', 'NotInteractive', 'used_in_import_edited_files']
-- Description: Increment edits done in dicom_edit_event table
-- For use in scripts
-- Not really intended for interactive use
-- 

update dicom_edit_event
  set time_completed = now(),
  report_file = ?,
  notification_sent = ?
where
  dicom_edit_event_id = ?