-- Name: LinkEmailToActivity
-- Schema: posda_queries
-- Columns: []
-- Args: ['activity_id', 'user_inbox_content_id']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

insert into activity_inbox_content(
 activity_id, user_inbox_content_id
) values (
  ?, ?
)