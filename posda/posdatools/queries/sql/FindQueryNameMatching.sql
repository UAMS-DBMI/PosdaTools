-- Name: FindQueryNameMatching
-- Schema: posda_queries
-- Columns: ['name']
-- Args: ['name_matching']
-- Tags: ['meta', 'test', 'hello']
-- Description: Find all queries with name matching arg

select
  distinct name
from
  queries
where
  name ~ ?
order by name