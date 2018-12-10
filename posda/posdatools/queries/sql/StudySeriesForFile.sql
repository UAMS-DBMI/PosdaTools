-- Name: StudySeriesForFile
-- Schema: posda_files
-- Columns: ['study_instance_uid', 'series_instance_uid']
-- Args: ['file_id']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

select study_instance_uid, series_instance_uid from file_series natural join file_study where file_id = ?