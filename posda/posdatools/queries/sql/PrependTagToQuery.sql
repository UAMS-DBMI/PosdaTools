-- Name: PrependTagToQuery
-- Schema: posda_queries
-- Columns: []
-- Args: ['tag', 'name']
-- Tags: ['meta', 'test', 'hello', 'query_tags']
-- Description: Add a tag to a query

update queries
set tags = array_prepend(?, tags)
where name = ?