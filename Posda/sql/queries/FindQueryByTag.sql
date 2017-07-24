-- Name: FindQueryByTag
-- Schema: posda_queries
-- Columns: ['name']
-- Args: ['tag_name']
-- Tags: ['meta', 'test', 'hello']
-- Description: Find all queries matching tag

select
  distinct name from (
  select name, unnest(tags) as tag
  from queries) as foo
where
  tag = ?