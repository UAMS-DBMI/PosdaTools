-- Name: GetUnreadInboxCount
-- Schema: posda_queries
-- Columns: ['count']
-- Args: ['user_name']
-- Tags: []
-- Description: Get a count of unread messages from the user's inbox.

select count(*) as count
from user_inbox_content 
natural join user_inbox 
where date_dismissed is null
  and user_name = ?
