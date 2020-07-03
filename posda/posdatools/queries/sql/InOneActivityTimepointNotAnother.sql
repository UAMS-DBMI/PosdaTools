-- Name: InOneActivityTimepointNotAnother
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['from_activity_timepoint', 'two_activity_timepoint']
-- Tags: ['activity_timepoints']
-- Description:  Get files in timepoint
--

select 
  (select file_id from activity_timepoint_file where activity_timepoint_id = ?)
excluding
  (select file_id from activity_timepoint_file where activity_timepoint_id = ?)