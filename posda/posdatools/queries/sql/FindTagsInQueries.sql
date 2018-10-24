-- Name: FindTagsInQueries
-- Schema: posda_queries
-- Columns: ['tag']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tags']
-- Description: Find all queries matching tag

select
  distinct tag from (
  select name, unnest(tags) as tag
  from queries) as foo
order by tag