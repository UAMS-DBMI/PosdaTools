-- Name: DeleteLastTagFromQuery
-- Schema: posda_queries
-- Columns: []
-- Args: ['name']
-- Tags: ['meta', 'test', 'hello', 'query_tags']
-- Description: Add a tag to a query

update queries 
  set tags = tags[1:(array_upper(tags,1) -1)]
where name = ?