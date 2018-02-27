-- Name: GetUnreadInboxItems
-- Schema: posda_queries
-- Columns: ['user_inbox_content_id', 'background_subprocess_report_id', 'current_status', 'date_entered']
-- Args: ['user_name']
-- Tags: []
-- Description: Get a list of unread messages from the user's inbox.

select
  user_inbox_content_id,
  background_subprocess_report_id,
  current_status,
  date_entered
from user_inbox_content 
natural join user_inbox 
where date_dismissed is null
  and user_name = ?
