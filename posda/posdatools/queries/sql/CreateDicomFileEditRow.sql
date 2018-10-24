-- Name: CreateDicomFileEditRow
-- Schema: posda_files
-- Columns: []
-- Args: ['dicom_edit_event_id', 'from_file_digest', 'to_file_digest']
-- Tags: ['Insert', 'NotInteractive', 'used_in_import_edited_files']
-- Description: Insert dicom_edit_event row
-- For use in scripts
-- Not really intended for interactive use
-- 

insert into dicom_file_edit(
  dicom_edit_event_id, from_file_digest, to_file_digest
) values (?, ?, ?)
