-- Name: GetUploadStatistics
-- Schema: posda_files
-- Columns: ['import_type', 'latest', 'earliest', 'num_import_events', 'num_files']
-- Args: []
-- Tags: ['statistics']
-- Description:  Get Summary of import events
--

select
  distinct import_type, max(import_time) as latest, min(import_time) as earliest,
  count(distinct import_event_id) as num_import_events, count(distinct file_id) as num_files
from
  import_event natural join file_import
group by import_type
order by latest desc