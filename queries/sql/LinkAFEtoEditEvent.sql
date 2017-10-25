-- Name: LinkAFEtoEditEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['dicom_edit_event_id', 'adverse_file_event_id']
-- Tags: ['Insert', 'NotInteractive', 'used_in_import_edited_files']
-- Description: Insert row linking adverse_file_edit_event to dicom_edit_event
-- For use in scripts
-- Not really intended for interactive use
-- 

insert into dicom_edit_event_adverse_file_event(
  dicom_edit_event_id, adverse_file_event_id
) values (?, ?)
