-- Name: GetUploadStatisticsApi
-- Schema: posda_files
-- Columns: ['import_type', 'import_comment', 'latest', 'earliest', 'num_import_events', 'num_files']
-- Args: ['import_type']
-- Tags: ['statistics']
-- Description:  Get Summary of import events by import_type
--

 select
  distinct import_type, import_comment, min(import_time) as earliest, max(import_time) as latest,
  count(distinct import_event_id) as num_import_events, count(distinct file_id) as num_files
from
  import_event natural join file_import where import_type = ?
group by import_type, import_comment
order by num_import_events desc