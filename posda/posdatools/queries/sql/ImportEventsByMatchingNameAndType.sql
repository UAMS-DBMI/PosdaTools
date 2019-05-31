-- Name: ImportEventsByMatchingNameAndType
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_type', 'import_comment', 'import_time', 'duration', 'num_images']
-- Args: ['import_comment_like', 'import_type_like']
-- Tags: ['import_events']
-- Description: Get Import Events by matching comment

select
  import_event_id, import_type,
  import_comment, import_time, import_close_time - import_time as duration, 
  count(distinct file_id) as num_images
from 
  import_event natural join file_import
where
  import_comment like ? and import_type like ?
group by import_event_id, import_type, import_comment, import_time, import_close_time