-- Name: GetAllQueries
-- Schema: posda_queries
-- Columns: ['name', 'query', 'args', 'columns', 'tags', 'schema', 'description']
-- Args: []
-- Tags: ['queries']
-- Description: Add a filter to a tab
--

select
  name, query, args, columns, tags, schema, description
from
  queries
