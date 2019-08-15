-- Name: GetQueryByName
-- Schema: posda_queries
-- Columns: ['name', 'query', 'args', 'columns', 'tags', 'schema', 'description']
-- Args: ['name']
-- Tags: ['bills_test', 'posda_db_populate']
-- Description: Add a filter to a tab
--

select name, query, args, columns, tags, schema, description
from queries where name = ?