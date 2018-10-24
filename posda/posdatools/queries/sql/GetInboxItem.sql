-- Name: GetInboxItem
-- Schema: posda_queries
-- Columns: ['current_status', 'status_note', 'date_entered', 'date_dismissed', 'file_id']
-- Args: ['user_inbox_content_id']
-- Tags: []
-- Description: Get the details of a single Inbox item.

select
	current_status,
	statuts_note,
	date_entered,
	date_dismissed,
	file_id
from user_inbox_content
natural join background_subprocess_report
where user_inbox_content_id = ?

