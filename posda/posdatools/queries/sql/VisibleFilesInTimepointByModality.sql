-- Name: VisibleFilesInTimepointByModality
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['modality', 'activity_id']
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Get all visible files in timepoint with specified modality
--

select file_id, visibility
from activity_timepoint_file natural left join ctp_file natural join file_series
where modality = ?
and activity_timepoint_id in (
  select max(activity_timepoint_id) as activity_timepoint_id
  from activity_timepoint where activity_id = ?
)