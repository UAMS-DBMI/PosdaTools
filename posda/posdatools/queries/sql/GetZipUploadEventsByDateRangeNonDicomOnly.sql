-- Name: GetZipUploadEventsByDateRangeNonDicomOnly
-- Schema: posda_files
-- Columns: ['import_event_id', 'num_files']
-- Args: ['from', 'to']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select distinct import_event_id, import_time, count (distinct file_id) as num_files from (
  select import_event_id, file_id, import_time, rel_path, file_type
  from file_import natural join import_event join file using(file_id)
  where import_time > ? and import_time < ? and import_comment = 'zip'
  and (rel_path like '%.docx' or rel_path like '%.xls' or rel_path like '%.xlsx' or rel_path like '%.csv')
) as foo
group by import_event_id, import_time