-- Name: FilesAndLoadTimesInSeries
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'import_time', 'file_id']
-- Args: ['series_instance_uid']
-- Tags: ['by_series']
-- Description: List of SOPs, files, and import times in a series
-- 

select
  distinct sop_instance_uid, file_id, import_time
from
  file_sop_common natural join file_series
  natural join file_import natural join import_event
where
  series_instance_uid = ?
order by 
  sop_instance_uid, import_time, file_id
