-- Name: CloseActivity
-- Schema: posda_queries
-- Columns: []
-- Args: ['activity_id']
-- Tags: ['activity_timepoint_support', 'activities']
-- Description: Close an activity
-- 
-- 

update activity set
  when_closed = now()
where
  activity_id = ?