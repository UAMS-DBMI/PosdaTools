-- Name: InboxEmailToUsername
-- Schema: posda_queries
-- Columns: ['user_name']
-- Args: ['user_email_addr']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Convert an email address to a username

select user_name
from user_inbox
where user_email_addr = ?

