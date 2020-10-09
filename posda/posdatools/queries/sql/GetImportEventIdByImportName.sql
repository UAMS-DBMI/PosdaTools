-- Name: GetImportEventIdByImportName
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_time', 'duration', 'num_files']
-- Args: ['import_comment']
-- Tags: ['import_events', 'copy_from_public']
-- Description: Get the import_event_id. and number of files imported by import_comment
-- 

select
  distinct import_event_id, 
  import_time,
  import_close_time - import_time as duration,
  count(distinct file_id) as num_files                                                                                                                                                                                                                                                                                                                                                                                                                              from
  import_event natural join file_import
where
  import_comment = ?
group by import_event_id, import_time, duration