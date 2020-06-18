-- Name: UnhideFilesInActivityTimepoint
-- Schema: posda_files
-- Columns: []
-- Args: ['activity_timepoint_id']
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: unhide files in activity_timepoint
--

update ctp_file
set visibility = null
where file_id in (
  select file_id 
  from activity_timepoint_file
  where activity_timepoint_id = ?)