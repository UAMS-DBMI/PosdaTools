-- Name: SeriesByMatchingImportEventsWithEventInfoAndFileCount
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_type', 'import_comment', 'import_time', 'series_instance_uid', 'num_files']
-- Args: ['import_comment_like', 'import_type_like']
-- Tags: ['find_series', 'import_events']
-- Description: Get Series by Import Events by matching 

select
distinct import_event_id, import_type, import_comment, import_time, series_instance_uid,
 count(distinct file_id) as num_files
from
  file_series natural join file_import natural join import_event
where import_event_id in (
  select
    import_event_id
  from 
    import_event
  where
    import_comment like ? 
    and
    import_type like ?
)
group by import_event_id, import_type, import_comment, import_time, series_instance_uid
order by import_event_id desc

