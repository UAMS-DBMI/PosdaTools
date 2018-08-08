-- Name: InsertActivityTimepointFile
-- Schema: posda_queries
-- Columns: []
-- Args: ['actiity_id', 'file_id']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

insert into activity_timepoint_file(
  activity_timepoint_id, file_id
) values (
  ?, ?
)