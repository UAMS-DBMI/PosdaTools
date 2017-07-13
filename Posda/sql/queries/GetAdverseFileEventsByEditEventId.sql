-- Name: GetAdverseFileEventsByEditEventId
-- Schema: posda_files
-- Columns: ['adverse_file_event_id', 'file_id', 'event_description', 'when_occured']
-- Args: ['dicom_edit_event_id']
-- Tags: ['NotInteractive', 'used_in_import_edited_files']
-- Description: Get List of Adverse File Events for a given dicom_edit_event
-- For use in scripts
-- Not really intended for interactive use
-- 

select
  adverse_file_event_id,
  file_id,
  event_description,
  when_occured
from
  adverse_file_event natural join
  dicom_edit_event_adverse_file_event
where
  dicom_edit_event_id = ?