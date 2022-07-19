-- Name: AllImportEventsDateRange
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_comment', 'import_time', 'import_close_time', 'num_images']
-- Args: ['import_comment_like', 'from', 'to']
-- Tags: ['downloads_by_date', 'import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow']
-- Description: Counts query by Collection, Site
-- 

select
  import_event_id, import_comment, import_time, import_close_time, count(distinct file_id) as num_images
from 
  import_event natural join file_import
where
  import_comment like ? 
  and import_time > ? and import_time < ?
group by import_event_id, import_comment, import_time, import_close_time