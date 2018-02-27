-- Name: GetAllInboxItems
-- Schema: posda_queries
-- Columns: ['user_inbox_content_id', 'background_subprocess_report_id', 'current_status', 'date_entered']
-- Args: ['user_name']
-- Tags: []
-- Description: Get a list of all messages from the user's inbox.

select
  user_inbox_content_id,
  background_subprocess_report_id,
  current_status,
  date_entered
from user_inbox_content 
natural join user_inbox
where user_name = ?
order by date_entered desc
