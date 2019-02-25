-- Name: SummaryOfSingleFileImportEventsByDateRange
-- Schema: posda_files
-- Columns: ['import_type', 'import_comment', 'earliest', 'latest', 'num_imports']
-- Args: ['from', 'to']
-- Tags: ['downloads_by_date', 'import_events']
-- Description: Counts query by Collection, Site
-- 

select 
  distinct import_type, import_comment, min(import_time) as earliest, max(import_time) as latest,
  count(distinct import_event_id) as num_imports
from (
  select * 
  from (
    select
      distinct import_event_id, import_time, import_type, import_comment, count(distinct file_id)
    from
      import_event natural join file_import 
    where
      import_time > ?
      and import_time < ?
     group by import_event_id, import_time, import_type, import_comment
     order by import_time desc
  ) as foo where count = 1
) as foo 
group by import_type, import_comment;