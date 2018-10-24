-- Name: GetZipUploadEventsByDateRange
-- Schema: posda_files
-- Columns: ['import_event_id', 'num_files']
-- Args: ['from', 'to']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select distinct import_event_id, count(distinct file_id)  as num_files 
from file_import natural join import_event
where
import_time > ? and import_time < ? and import_comment = 'zip'
group by import_event_id