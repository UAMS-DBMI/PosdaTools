-- Name: RemoveTagFromQuery
-- Schema: posda_queries
-- Columns: []
-- Args: ['tag_name', 'query_name']
-- Tags: ['meta']
-- Description: Remove a tag from a query

update queries
set tags = array_remove(tags, ?::text)
where name = ?