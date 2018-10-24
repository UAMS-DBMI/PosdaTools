-- Name: DismissInboxItem
-- Schema: posda_queries
-- Columns: []
-- Args: ['user_inbox_content_id']
-- Tags: []
-- Description: Set the date_dismissed value on an Inbox item


update user_inbox_content
set date_dismissed = now()
where user_inbox_content_id = ?

