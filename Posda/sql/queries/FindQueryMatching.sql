-- Name: FindQueryMatching
-- Schema: posda_queries
-- Columns: ['name']
-- Args: ['query_matching']
-- Tags: ['meta', 'test', 'hello']
-- Description: Find all queries with name matching arg

select
  distinct name
from
  queries
where
  query ~ ?
order by name