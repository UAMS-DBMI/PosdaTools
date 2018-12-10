-- Name: SeriesForFile
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['file_id']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

select series_instance_uid from file_series where file_id = ?