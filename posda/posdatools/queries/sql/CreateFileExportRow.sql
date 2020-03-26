-- Name: CreateFileExportRow
-- Schema: posda_files
-- Columns: []
-- Args: ['export_event_id', 'file_id']
-- Tags: ['export_event']
-- Description: Creates a file_export row for a file related to an export_event
--

insert into file_export (
<<<<<<< HEAD
 export_event_id, file_id, when_queued
=======
 export_even_id, file_id, when_qiueued
>>>>>>> Initial working copy of ExportTimepoint operation
) values (
  ?,  ?, now()
)