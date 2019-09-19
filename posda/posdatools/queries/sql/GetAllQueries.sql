-- Name: GetAllQueries
-- Schema: posda_files
-- Columns: ['name', 'query', 'args', 'columns', 'tags', 'schema', 'description']
-- Args: []
-- Tags: ['queries']
-- Description: Get all named queries


select
  name, query, args, columns, tags, schema, description
from
  queries