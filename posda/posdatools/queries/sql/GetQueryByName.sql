-- Name: GetQueryByName
-- Schema: posda_queries
-- Columns: ['name', 'query', 'args', 'columns', 'tags', 'schema', 'description']
-- Args: ['name']
-- Tags: ['bills_test']
-- Description: Get query by name
--

select name, query, args, columns, tags, schema, description
from queries where name = ?