-- Name: ImportEventsByOriginActiveRate
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_comment', 'import_expected_count', 'num_files', 'latest_import', 'current_duration', 'current_rate']
-- Args: ['import_origin']
-- Tags: ['posda_to_posda']
-- Description: Report on incoming Posda to Posda Transfers by Origin with byte rate
-- 

select
  import_event_id,import_comment,
  import_expected_count, count(distinct file_id) as num_files,
  sum(size) as num_bytes,
  max(file_import_time) as latest_import,
  max(file_import_time) - import_time as current_duration,
  ((cast(sum(size)as float))/(extract (epoch from(max(file_import_time) - import_time)))) as current_rate
from
  import_event natural join file_import natural join file
where
  import_origin = ? and import_close_time is null
group by import_event_id, import_comment,  import_expected_count, import_time;