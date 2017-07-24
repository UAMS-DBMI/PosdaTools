-- Name: FindTagsInQuery
-- Schema: posda_queries
-- Columns: ['tag']
-- Args: ['name']
-- Tags: ['meta', 'test', 'hello', 'query_tags']
-- Description: Find all queries matching tag

select
  tag from (
  select name, unnest(tags) as tag
  from queries) as foo
where
  name = ?