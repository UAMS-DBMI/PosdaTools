-- Name: GetActivityTimepointId
-- Schema: posda_queries
-- Columns: ['id']
-- Args: []
-- Tags: ['by_collection', 'activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

select currval('activity_timepoint_activity_timepoint_id_seq') as id