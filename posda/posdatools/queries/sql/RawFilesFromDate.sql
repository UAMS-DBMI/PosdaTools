-- Name: RawFilesFromDate
-- Schema: posda_files
-- Columns: ['file_type', 'max_file_id', 'min_file_id', 'num_files', 'largest', 'smallest', 'total_size', 'avg_size']
-- Args: ['date_type', 'from']
-- Tags: ['downloads_by_date']
-- Description: Counts query by Collection, Site
-- 

select 
  file_type, max(file_id) as max_file_id, min(file_id) as min_file_id, 
  count(*) as num_files, max(size) as largest, min(size) as smallest,
  sum(size) as total_size, avg(size) as avg_size
from file
where file_id in (
  select
    file_id from (
      select
        distinct file_id, date_trunc(?, min(import_time)) as load_week
      from
        file_import natural join import_event
      group by file_id
  ) as foo
  where
    load_week >=? and load_week <  (now() + interval '24:00:00')
) 
group by file_type