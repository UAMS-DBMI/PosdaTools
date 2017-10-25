-- Name: InsertAdverseFileEvent
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'event_description']
-- Tags: ['Insert', 'NotInteractive', 'used_in_import_edited_files']
-- Description: Insert adverse_file_event row
-- For use in scripts
-- Not really intended for interactive use
-- 

insert into adverse_file_event(
  file_id, event_description, when_occured
) values (?, ?, now())
