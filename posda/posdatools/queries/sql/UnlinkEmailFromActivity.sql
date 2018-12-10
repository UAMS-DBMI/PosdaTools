-- Name: UnlinkEmailFromActivity
-- Schema: posda_queries
-- Columns: []
-- Args: ['activity_id', 'user_inbox_content_id']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

delete from activity_inbox_content
where activity_id = ? and user_inbox_content_id = ?