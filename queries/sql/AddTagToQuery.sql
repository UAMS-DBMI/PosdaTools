-- Name: AddTagToQuery
-- Schema: posda_queries
-- Columns: []
-- Args: ['tag', 'name']
-- Tags: ['query_tags', 'meta', 'test', 'hello']
-- Description: Add a tag to a query

update queries
set tags = array_append(tags, ?)
where name = ?