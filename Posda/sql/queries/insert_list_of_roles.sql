-- Name: insert_list_of_roles
-- Schema: posda_queries
-- Columns: []
-- Args: ['tag_list', 'role']
-- Tags: ['roles']
-- Description: Insert a list of tags for a role
-- 

update query_tag_filter
set tags_enabled = ?
where filter_name = ?