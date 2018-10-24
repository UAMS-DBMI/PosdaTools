-- Name: DeleteFirstTagFromQuery
-- Schema: posda_queries
-- Columns: []
-- Args: ['name']
-- Tags: ['meta', 'test', 'hello', 'query_tags']
-- Description: Add a tag to a query

update queries 
  set tags = tags[(array_lower(tags,1) + 1):(array_upper(tags,1))]
where name = ?